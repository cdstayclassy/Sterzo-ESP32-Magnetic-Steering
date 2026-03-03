"""
Steering Overlay — live steering angle display for GTBikeV.

The connection mode is chosen from the dropdown in the overlay window:
  • BLE           — Bluetooth direct (use when not in-game)
  • /dev/cu.xxx   — USB serial port  (use while GTBikeV is running)

Usage:
    python overlay.py              # launch overlay
    python overlay.py --list-ports # list available serial ports and exit
    python overlay.py --baud 115200  # override baud rate (default: 115200)
"""

import argparse
import asyncio
import math
import queue
import struct
import threading
import time
import tkinter as tk

from bleak import BleakClient, BleakScanner

# ── BLE constants ─────────────────────────────────────────────────────────────
SERVICE_UUID = "347b0001-7635-408b-8918-8ff3949ce592"
CHAR30_UUID  = "347b0030-7635-408b-8918-8ff3949ce592"
DEVICE_NAME  = "ESP32 Steering"

RECONNECT_DELAY = 3   # seconds between reconnect attempts

# ── Shared state ──────────────────────────────────────────────────────────────
angle_queue: queue.Queue = queue.Queue(maxsize=10)
stop_event        = threading.Event()   # set to shut down the app

# connection_mode[0] is either "ble" or a serial port device path.
# mode_change_event is set whenever connection_mode[0] is updated so the
# supervisor thread wakes up and reconnects with the new mode.
connection_mode   = ["ble"]
mode_change_event = threading.Event()


# ── Serial port helpers ───────────────────────────────────────────────────────

def _list_serial_ports():
    """Return [(device, label), ...] for non-trivial serial ports."""
    try:
        import serial.tools.list_ports
    except ImportError:
        return []

    skip = ("debug-console", "bluetooth-incoming")
    result = []
    for p in serial.tools.list_ports.comports():
        if any(s in p.device.lower() for s in skip):
            continue
        desc = p.description or ""
        label = f"{p.device}  —  {desc}" if desc and desc.lower() != "n/a" else p.device
        result.append((p.device, label))
    return result



# ── Supervisor thread ─────────────────────────────────────────────────────────

def supervisor_thread(baud: int):
    """Launch BLE or serial sub-loop based on connection_mode[0].
    Re-launches automatically whenever the user changes the dropdown."""
    while not stop_event.is_set():
        mode_change_event.clear()
        mode = connection_mode[0]
        angle_queue.put(("status", "disconnected"))

        if mode == "ble":
            asyncio.run(_ble_main())
        else:
            _serial_loop(mode, baud)

        # After sub-loop exits (mode change, disconnect, or stop):
        if not stop_event.is_set() and not mode_change_event.is_set():
            angle_queue.put(("status", "disconnected"))
            time.sleep(RECONNECT_DELAY)


# ── BLE sub-loop ──────────────────────────────────────────────────────────────

async def _ble_main():
    while not stop_event.is_set() and not mode_change_event.is_set():
        angle_queue.put(("status", "scanning"))
        device = await _scan()
        if device is None:
            await asyncio.sleep(RECONNECT_DELAY)
            continue

        angle_queue.put(("status", "connecting"))
        try:
            async with BleakClient(device) as client:
                angle_queue.put(("status", "connected"))

                def _notify(_, data: bytearray):
                    if len(data) >= 4:
                        angle = struct.unpack("<f", data[:4])[0]
                        if angle_queue.full():
                            try:
                                angle_queue.get_nowait()
                            except queue.Empty:
                                pass
                        angle_queue.put(("angle", angle))

                await client.start_notify(CHAR30_UUID, _notify)

                while (client.is_connected
                       and not stop_event.is_set()
                       and not mode_change_event.is_set()):
                    await asyncio.sleep(0.5)

                await client.stop_notify(CHAR30_UUID)
        except Exception:
            pass

        if not stop_event.is_set() and not mode_change_event.is_set():
            angle_queue.put(("status", "disconnected"))
            await asyncio.sleep(RECONNECT_DELAY)


async def _scan():
    try:
        return await BleakScanner.find_device_by_filter(
            lambda d, adv: (
                SERVICE_UUID.lower() in [s.lower() for s in (adv.service_uuids or [])]
                or (d.name and DEVICE_NAME.lower() in d.name.lower())
            ),
            timeout=10.0,
        )
    except Exception:
        return None


# ── Serial sub-loop ───────────────────────────────────────────────────────────

def _serial_loop(port: str, baud: int):
    import serial as pyserial

    while not stop_event.is_set() and not mode_change_event.is_set():
        angle_queue.put(("status", "connecting"))
        try:
            with pyserial.Serial(port, baud, timeout=1) as ser:
                angle_queue.put(("status", "connected"))
                while not stop_event.is_set() and not mode_change_event.is_set():
                    try:
                        line = ser.readline().decode("utf-8", errors="ignore").strip()
                    except Exception:
                        break
                    if line.startswith("ntf angle "):
                        try:
                            angle = float(line[len("ntf angle "):])
                            if angle_queue.full():
                                try:
                                    angle_queue.get_nowait()
                                except queue.Empty:
                                    pass
                            angle_queue.put(("angle", angle))
                        except ValueError:
                            pass
        except Exception:
            pass

        if not stop_event.is_set() and not mode_change_event.is_set():
            angle_queue.put(("status", "disconnected"))
            time.sleep(RECONNECT_DELAY)


# ── Tkinter UI ────────────────────────────────────────────────────────────────

ANGLE_MIN      = -40.0
ANGLE_MAX      =  40.0

# Arc (steering wheel) geometry
ARC_W          = 260          # canvas width
ARC_H          = 110          # canvas height
ARC_CX         = ARC_W // 2  # arc pivot x (centre)
ARC_CY         = ARC_H - 2   # arc pivot y (near bottom edge)
ARC_R          = 85           # track radius
ARC_NEEDLE_R   = 76           # needle tip radius (inside the track)
ARC_HALF_SPAN  = 65           # visual degrees from centre to each end
ARC_TRACK_W    = 6            # track stroke width

BG          = "#1a1a1a"
FG          = "#ffffff"
TRACK_COLOR = "#444444"
INDICATOR   = "#00aaff"
GREEN       = "#00cc44"
YELLOW      = "#ffcc00"
RED         = "#ff4444"
BADGE_BLE   = "#1a4a6e"
BADGE_USB   = "#3a2a6e"
BTN_FG      = "#888888"

BLE_LABEL   = "BLE  —  Bluetooth (testing only)"


def _steering_to_angles(steering: float):
    """Return (visual_deg, extent_deg) for a steering value in [-40, 40].

    visual_deg  — angle of the needle in tkinter/math convention
                  (0=east, counterclockwise; 90=top).
    extent_deg  — signed arc extent for the fill arc starting at 90°
                  (negative = clockwise = right turn).
    """
    clamped = max(ANGLE_MIN, min(ANGLE_MAX, steering))
    visual_deg = 90.0 - (clamped / ANGLE_MAX) * ARC_HALF_SPAN
    extent_deg = -(clamped / ANGLE_MAX) * ARC_HALF_SPAN
    return visual_deg, extent_deg


class OverlayApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self._port_map: dict[str, str] = {}   # dropdown label → device path (or "ble")
        self._build_window()
        self._build_widgets()
        self._drag_x = 0
        self._drag_y = 0
        self._bind_drag()
        self._poll()

    # ── Window ────────────────────────────────────────────────────────────────

    def _build_window(self):
        root = self.root
        root.title("Steering Overlay")
        root.configure(bg=BG)
        root.resizable(False, False)
        root.attributes("-topmost", True)
        root.overrideredirect(True)

        w, h = 300, 265
        sw = root.winfo_screenwidth()
        sh = root.winfo_screenheight()
        root.geometry(f"{w}x{h}+{(sw - w) // 2}+{(sh - h) // 2}")

    # ── Widgets ───────────────────────────────────────────────────────────────

    def _build_widgets(self):
        root = self.root

        # Title row
        title_frame = tk.Frame(root, bg=BG)
        title_frame.pack(fill="x", padx=8, pady=(6, 0))

        tk.Label(
            title_frame, text="Steering Angle", bg=BG, fg="#aaaaaa",
            font=("Segoe UI", 9)
        ).pack(side="left")

        self.badge = tk.Label(
            title_frame, text="BLE", bg=BADGE_BLE, fg="#aaaaaa",
            font=("Segoe UI", 7), padx=4, pady=1
        )
        self.badge.pack(side="left", padx=(6, 0))

        close_btn = tk.Label(
            title_frame, text="✕", bg=BG, fg=BTN_FG,
            font=("Segoe UI", 9), cursor="hand2"
        )
        close_btn.pack(side="right")
        close_btn.bind("<Button-1>", lambda _: self._on_close())

        # Steering arc
        self.canvas = tk.Canvas(
            root, width=ARC_W, height=ARC_H, bg=BG, highlightthickness=0
        )
        self.canvas.pack(padx=10, pady=(4, 0))
        self._draw_arc()

        # Angle readout
        self.angle_label = tk.Label(
            root, text="—°", bg=BG, fg=FG, font=("Segoe UI", 28, "bold")
        )
        self.angle_label.pack(padx=10, pady=(2, 0))

        # Status row
        status_frame = tk.Frame(root, bg=BG)
        status_frame.pack(fill="x", padx=10, pady=(2, 4))

        self.status_dot = tk.Canvas(
            status_frame, width=10, height=10, bg=BG, highlightthickness=0
        )
        self.status_dot.pack(side="left", padx=(0, 4))
        self._dot_id = self.status_dot.create_oval(1, 1, 9, 9, fill=YELLOW, outline="")

        self.status_label = tk.Label(
            status_frame, text="Connecting…", bg=BG, fg="#aaaaaa",
            font=("Segoe UI", 9)
        )
        self.status_label.pack(side="left")

        # Connection picker row
        picker_frame = tk.Frame(root, bg=BG)
        picker_frame.pack(fill="x", padx=10, pady=(2, 8))

        tk.Label(
            picker_frame, text="Via:", bg=BG, fg="#666666",
            font=("Segoe UI", 8)
        ).pack(side="left")

        self.mode_var = tk.StringVar(value=BLE_LABEL)
        self.mode_menu = tk.OptionMenu(
            picker_frame, self.mode_var, BLE_LABEL,
            command=self._on_mode_selected
        )
        self.mode_menu.config(
            bg="#2a2a2a", fg="#dddddd", activebackground="#3a3a3a",
            activeforeground="white", highlightthickness=0,
            relief="flat", bd=0, font=("Segoe UI", 8), cursor="hand2"
        )
        self.mode_menu["menu"].config(
            bg="#2a2a2a", fg="#dddddd",
            activebackground="#3a3a3a", activeforeground="white",
            font=("Segoe UI", 8), bd=0
        )
        self.mode_menu.pack(side="left", padx=(4, 2))

        refresh_btn = tk.Label(
            picker_frame, text="↺", bg=BG, fg=BTN_FG,
            font=("Segoe UI", 12), cursor="hand2"
        )
        refresh_btn.pack(side="left")
        refresh_btn.bind("<Button-1>", lambda _: self._refresh_menu())

        self._refresh_menu()

    def _refresh_menu(self):
        """Rebuild the dropdown with BLE + all available serial ports."""
        serial_ports = _list_serial_ports()

        # Build label→mode map
        self._port_map = {BLE_LABEL: "ble"}
        for device, label in serial_ports:
            self._port_map[label] = device

        labels = [BLE_LABEL] + [lbl for _, lbl in serial_ports]

        menu = self.mode_menu["menu"]
        menu.delete(0, "end")
        for lbl in labels:
            menu.add_command(
                label=lbl,
                command=lambda l=lbl: self._on_mode_selected(l)
            )

        # Keep current selection if still valid; otherwise reset to BLE
        current = self.mode_var.get()
        if current not in self._port_map:
            self.mode_var.set(BLE_LABEL)
            self._on_mode_selected(BLE_LABEL)

    def _on_mode_selected(self, label: str):
        mode = self._port_map.get(label, "ble")
        connection_mode[0] = mode
        mode_change_event.set()
        self.mode_var.set(label)

        # Update badge
        if mode == "ble":
            self.badge.config(text="BLE", bg=BADGE_BLE)
        else:
            self.badge.config(text="USB", bg=BADGE_USB)

        # Reset display
        self.angle_label.config(text="—°")
        self._move_needle(0.0)

    # ── Arc (steering wheel) ──────────────────────────────────────────────────

    def _draw_arc(self):
        c = self.canvas
        bb = (ARC_CX - ARC_R, ARC_CY - ARC_R,
              ARC_CX + ARC_R, ARC_CY + ARC_R)

        # Gray track arc spanning the full ±40° range
        c.create_arc(*bb,
                     start=90 - ARC_HALF_SPAN, extent=ARC_HALF_SPAN * 2,
                     style=tk.ARC, outline=TRACK_COLOR, width=ARC_TRACK_W)

        # Coloured fill arc — updated each frame, hidden at centre
        self._fill_arc = c.create_arc(*bb,
                                      start=90, extent=0.01,
                                      style=tk.ARC, outline=INDICATOR,
                                      width=ARC_TRACK_W, state="hidden")

        # Centre tick (straight-ahead mark)
        tick_in  = ARC_R - 8
        tick_out = ARC_R + 8
        c.create_line(ARC_CX, ARC_CY - tick_in,
                      ARC_CX, ARC_CY - tick_out,
                      fill=TRACK_COLOR, width=2)

        # Outer labels: -40°, 0°, +40°
        for deg, text, anchor in (
            (90 - ARC_HALF_SPAN, "+40°", "w"),   # right end
            (90,                 "0°",   "s"),   # top
            (90 + ARC_HALF_SPAN, "-40°", "e"),   # left end
        ):
            rad = math.radians(deg)
            lx = ARC_CX + (ARC_R + 12) * math.cos(rad)
            ly = ARC_CY - (ARC_R + 12) * math.sin(rad)
            c.create_text(lx, ly, text=text, fill="#555555",
                          font=("Segoe UI", 7), anchor=anchor)

        # Needle line (updated each frame)
        self._needle = c.create_line(
            ARC_CX, ARC_CY, ARC_CX, ARC_CY - ARC_NEEDLE_R,
            fill=FG, width=2, capstyle=tk.ROUND
        )

        # Pivot dot at centre
        r = 5
        c.create_oval(ARC_CX - r, ARC_CY - r,
                      ARC_CX + r, ARC_CY + r,
                      fill=FG, outline="")

    def _move_needle(self, angle: float):
        visual_deg, extent_deg = _steering_to_angles(angle)
        rad = math.radians(visual_deg)
        nx = ARC_CX + ARC_NEEDLE_R * math.cos(rad)
        ny = ARC_CY - ARC_NEEDLE_R * math.sin(rad)
        self.canvas.coords(self._needle, ARC_CX, ARC_CY, nx, ny)

        if abs(extent_deg) < 0.5:
            self.canvas.itemconfig(self._fill_arc, state="hidden")
        else:
            self.canvas.itemconfig(self._fill_arc,
                                   state="normal", extent=extent_deg)

    # ── Drag ─────────────────────────────────────────────────────────────────

    def _bind_drag(self):
        self.root.bind("<ButtonPress-1>", self._drag_start)
        self.root.bind("<B1-Motion>",     self._drag_move)

    def _drag_start(self, event):
        self._drag_x = event.x_root - self.root.winfo_x()
        self._drag_y = event.y_root - self.root.winfo_y()

    def _drag_move(self, event):
        x = event.x_root - self._drag_x
        y = event.y_root - self._drag_y
        self.root.geometry(f"+{x}+{y}")

    # ── Poll ──────────────────────────────────────────────────────────────────

    def _poll(self):
        try:
            while True:
                msg_type, value = angle_queue.get_nowait()
                if msg_type == "angle":
                    self._update_angle(value)
                elif msg_type == "status":
                    self._update_status(value)
        except queue.Empty:
            pass
        self.root.after(50, self._poll)

    def _update_angle(self, angle: float):
        self.angle_label.config(text=f"{angle:+.1f}°")
        self._move_needle(angle)

    def _update_status(self, status: str):
        if status == "connected":
            color, text = GREEN,  "Connected"
        elif status == "scanning":
            color, text = YELLOW, "Scanning…"
        elif status == "connecting":
            color, text = YELLOW, "Connecting…"
        else:
            color, text = RED,    "Disconnected"
        self.status_dot.itemconfig(self._dot_id, fill=color)
        self.status_label.config(text=text)

    # ── Close ─────────────────────────────────────────────────────────────────

    def _on_close(self):
        stop_event.set()
        mode_change_event.set()   # unblock any sleeping supervisor
        self.root.destroy()


# ── Entry point ───────────────────────────────────────────────────────────────

def _print_ports():
    ports = _list_serial_ports()
    if not ports:
        print("No serial ports found.")
    for _, label in ports:
        print(f"  {label}")


def main():
    parser = argparse.ArgumentParser(description="Steering angle overlay for GTBikeV")
    parser.add_argument(
        "--baud", type=int, default=115200,
        help="Serial baud rate (default: 115200)"
    )
    parser.add_argument(
        "--list-ports", action="store_true",
        help="List available serial ports and exit"
    )
    args = parser.parse_args()

    if args.list_ports:
        _print_ports()
        return

    t = threading.Thread(target=supervisor_thread, args=(args.baud,), daemon=True)
    t.start()

    root = tk.Tk()
    app = OverlayApp(root)
    root.protocol("WM_DELETE_WINDOW", app._on_close)
    root.mainloop()

    stop_event.set()
    mode_change_event.set()


if __name__ == "__main__":
    main()
