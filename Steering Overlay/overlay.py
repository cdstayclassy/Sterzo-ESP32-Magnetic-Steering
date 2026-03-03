"""
Steering Overlay — live steering angle display for GTBikeV.

Modes:
    BLE    (default) — connects directly to ESP32 over Bluetooth
    Serial           — reads angle from ESP32 over USB serial cable

Usage:
    python overlay.py                                 # BLE mode
    python overlay.py --mode serial                   # USB serial, auto-detect port
    python overlay.py --mode serial --port /dev/cu.usbserial-0001
    python overlay.py --list-ports                    # list available serial ports
"""

import argparse
import asyncio
import queue
import struct
import threading
import time
import tkinter as tk

from bleak import BleakClient, BleakScanner

# ── BLE constants ────────────────────────────────────────────────────────────
SERVICE_UUID = "347b0001-7635-408b-8918-8ff3949ce592"
CHAR30_UUID  = "347b0030-7635-408b-8918-8ff3949ce592"
DEVICE_NAME  = "ESP32 Steering"

RECONNECT_DELAY = 3   # seconds between reconnect attempts

# ── Shared state between threads ─────────────────────────────────────────────
angle_queue: queue.Queue = queue.Queue(maxsize=10)
stop_event   = threading.Event()


# ── BLE background thread ─────────────────────────────────────────────────────

def ble_thread():
    """Run an asyncio event loop in a daemon thread for all BLE operations."""
    asyncio.run(_ble_main())


async def _ble_main():
    while not stop_event.is_set():
        angle_queue.put(("status", "scanning"))
        device = await _scan()
        if device is None:
            # scan timed out — try again
            await asyncio.sleep(RECONNECT_DELAY)
            continue

        angle_queue.put(("status", "connecting"))
        try:
            async with BleakClient(device) as client:
                angle_queue.put(("status", "connected"))

                def _notify(_, data: bytearray):
                    if len(data) >= 4:
                        angle = struct.unpack("<f", data[:4])[0]
                        # Discard stale items to keep the queue fresh
                        if angle_queue.full():
                            try:
                                angle_queue.get_nowait()
                            except queue.Empty:
                                pass
                        angle_queue.put(("angle", angle))

                await client.start_notify(CHAR30_UUID, _notify)

                # Keep alive until disconnected or stop requested
                while client.is_connected and not stop_event.is_set():
                    await asyncio.sleep(0.5)

                await client.stop_notify(CHAR30_UUID)
        except Exception:
            pass  # connection failed or dropped

        if not stop_event.is_set():
            angle_queue.put(("status", "disconnected"))
            await asyncio.sleep(RECONNECT_DELAY)


async def _scan():
    """Return a BleakDevice matching the Sterzo service UUID or device name."""
    try:
        device = await BleakScanner.find_device_by_filter(
            lambda d, adv: (
                SERVICE_UUID.lower() in [s.lower() for s in (adv.service_uuids or [])]
                or (d.name and DEVICE_NAME.lower() in d.name.lower())
            ),
            timeout=10.0,
        )
        return device
    except Exception:
        return None


# ── USB Serial background thread ──────────────────────────────────────────────

def _detect_serial_port():
    """Return the most likely ESP32 serial port, or None if not found."""
    try:
        import serial.tools.list_ports
    except ImportError:
        return None

    ESP32_KEYWORDS = (
        "cp210", "ch340", "ch341", "ftdi",
        "uart", "usb serial", "usb-serial",
        "jtag",          # ESP32-S3/C3 built-in USB ("USB JTAG/serial debug unit")
    )
    ports = list(serial.tools.list_ports.comports())

    # Prefer ports whose description/manufacturer matches known ESP32 USB chips,
    # or whose device path looks like a USB modem (ESP32 built-in USB on macOS)
    for p in ports:
        desc   = (p.description or "").lower()
        mfr    = (p.manufacturer or "").lower()
        device = (p.device or "").lower()
        if any(k in desc or k in mfr for k in ESP32_KEYWORDS):
            return p.device
        if "usbmodem" in device:
            return p.device

    # Skip debug-console and Bluetooth pseudo-ports; take the first real port
    skip = ("debug-console", "bluetooth")
    real = [p for p in ports if not any(s in p.device.lower() for s in skip)]
    return real[0].device if real else None


def serial_thread(port, baud):
    """Read 'ntf angle X.XX' lines from the ESP32 serial port."""
    import serial as pyserial

    while not stop_event.is_set():
        resolved_port = port or _detect_serial_port()
        if resolved_port is None:
            angle_queue.put(("status", "scanning"))
            time.sleep(RECONNECT_DELAY)
            continue

        angle_queue.put(("status", "connecting"))
        try:
            with pyserial.Serial(resolved_port, baud, timeout=1) as ser:
                angle_queue.put(("status", "connected"))
                while not stop_event.is_set():
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
            pass  # port not available or disconnected

        if not stop_event.is_set():
            angle_queue.put(("status", "disconnected"))
            time.sleep(RECONNECT_DELAY)


# ── Tkinter UI ────────────────────────────────────────────────────────────────

BAR_W        = 260   # canvas width
BAR_H        = 28    # canvas height
BAR_TRACK_Y  = BAR_H // 2
ANGLE_MIN    = -40.0
ANGLE_MAX    =  40.0
DIAMOND_R    = 8     # half-size of the indicator diamond

BG           = "#1a1a1a"
FG           = "#ffffff"
TRACK_COLOR  = "#444444"
INDICATOR    = "#00aaff"
GREEN        = "#00cc44"
YELLOW       = "#ffcc00"
RED          = "#ff4444"
BADGE_BLE    = "#1a4a6e"
BADGE_USB    = "#3a2a6e"


def _angle_to_x(angle: float) -> float:
    """Map angle (degrees) to canvas x coordinate."""
    frac = (angle - ANGLE_MIN) / (ANGLE_MAX - ANGLE_MIN)
    frac = max(0.0, min(1.0, frac))
    margin = DIAMOND_R + 4
    return margin + frac * (BAR_W - 2 * margin)


class OverlayApp:
    def __init__(self, root: tk.Tk, mode: str):
        self.root = root
        self.mode = mode  # "ble" or "serial"
        self._build_window()
        self._build_widgets()
        self._drag_x = 0
        self._drag_y = 0
        self._bind_drag()
        self._poll()

    # ── Window setup ──────────────────────────────────────────────────────────

    def _build_window(self):
        root = self.root
        root.title("Steering Overlay")
        root.configure(bg=BG)
        root.resizable(False, False)
        root.attributes("-topmost", True)
        root.overrideredirect(True)   # borderless / no taskbar entry

        # Centre on screen initially
        w, h = 300, 160
        sw = root.winfo_screenwidth()
        sh = root.winfo_screenheight()
        root.geometry(f"{w}x{h}+{(sw - w) // 2}+{(sh - h) // 2}")

    # ── Widgets ───────────────────────────────────────────────────────────────

    def _build_widgets(self):
        root = self.root
        # Title row with mode badge and close button
        title_frame = tk.Frame(root, bg=BG)
        title_frame.pack(fill="x", padx=8, pady=(6, 0))

        tk.Label(
            title_frame, text="Steering Angle", bg=BG, fg="#aaaaaa",
            font=("Segoe UI", 9)
        ).pack(side="left")

        badge_text = "BLE" if self.mode == "ble" else "USB"
        badge_bg   = BADGE_BLE if self.mode == "ble" else BADGE_USB
        tk.Label(
            title_frame, text=badge_text, bg=badge_bg, fg="#aaaaaa",
            font=("Segoe UI", 7), padx=4, pady=1
        ).pack(side="left", padx=(6, 0))

        close_btn = tk.Label(
            title_frame, text="✕", bg=BG, fg="#666666",
            font=("Segoe UI", 9), cursor="hand2"
        )
        close_btn.pack(side="right")
        close_btn.bind("<Button-1>", lambda _: self._on_close())

        # Steering bar canvas
        self.canvas = tk.Canvas(
            root, width=BAR_W, height=BAR_H,
            bg=BG, highlightthickness=0
        )
        self.canvas.pack(padx=10, pady=(4, 0))
        self._draw_bar()

        # Angle label
        self.angle_label = tk.Label(
            root, text="—°", bg=BG, fg=FG,
            font=("Segoe UI", 28, "bold")
        )
        self.angle_label.pack(padx=10, pady=(2, 0))

        # Status row
        status_frame = tk.Frame(root, bg=BG)
        status_frame.pack(fill="x", padx=10, pady=(2, 8))

        self.status_dot = tk.Canvas(
            status_frame, width=10, height=10,
            bg=BG, highlightthickness=0
        )
        self.status_dot.pack(side="left", padx=(0, 4))
        self._dot_id = self.status_dot.create_oval(1, 1, 9, 9, fill=YELLOW, outline="")

        self.status_label = tk.Label(
            status_frame, text="Scanning…", bg=BG, fg="#aaaaaa",
            font=("Segoe UI", 9)
        )
        self.status_label.pack(side="left")

    def _draw_bar(self):
        """Draw the static track and axis labels; create the moving indicator."""
        c = self.canvas
        margin = DIAMOND_R + 4

        # Track line
        c.create_line(
            margin, BAR_TRACK_Y, BAR_W - margin, BAR_TRACK_Y,
            fill=TRACK_COLOR, width=3
        )

        # Centre tick
        mid_x = BAR_W // 2
        c.create_line(mid_x, BAR_TRACK_Y - 5, mid_x, BAR_TRACK_Y + 5,
                      fill=TRACK_COLOR, width=1)

        # Labels
        c.create_text(margin, BAR_H - 2, text="-40°", fill="#666666",
                      font=("Segoe UI", 7), anchor="sw")
        c.create_text(mid_x, BAR_H - 2, text="0°", fill="#666666",
                      font=("Segoe UI", 7), anchor="s")
        c.create_text(BAR_W - margin, BAR_H - 2, text="+40°", fill="#666666",
                      font=("Segoe UI", 7), anchor="se")

        # Indicator diamond (starts at centre)
        cx = _angle_to_x(0.0)
        cy = BAR_TRACK_Y
        self._diamond = c.create_polygon(
            cx,              cy - DIAMOND_R,
            cx + DIAMOND_R,  cy,
            cx,              cy + DIAMOND_R,
            cx - DIAMOND_R,  cy,
            fill=INDICATOR, outline=FG, width=1
        )

    def _move_diamond(self, angle: float):
        cx = _angle_to_x(angle)
        cy = BAR_TRACK_Y
        self.canvas.coords(
            self._diamond,
            cx,              cy - DIAMOND_R,
            cx + DIAMOND_R,  cy,
            cx,              cy + DIAMOND_R,
            cx - DIAMOND_R,  cy,
        )

    # ── Drag to reposition ────────────────────────────────────────────────────

    def _bind_drag(self):
        self.root.bind("<ButtonPress-1>",  self._drag_start)
        self.root.bind("<B1-Motion>",      self._drag_move)

    def _drag_start(self, event):
        self._drag_x = event.x_root - self.root.winfo_x()
        self._drag_y = event.y_root - self.root.winfo_y()

    def _drag_move(self, event):
        x = event.x_root - self._drag_x
        y = event.y_root - self._drag_y
        self.root.geometry(f"+{x}+{y}")

    # ── Queue polling ─────────────────────────────────────────────────────────

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
        clamped = max(ANGLE_MIN, min(ANGLE_MAX, angle))
        self.angle_label.config(text=f"{angle:+.1f}°")
        self._move_diamond(clamped)

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

    # ── Shutdown ──────────────────────────────────────────────────────────────

    def _on_close(self):
        stop_event.set()
        self.root.destroy()


# ── Entry point ───────────────────────────────────────────────────────────────

def _list_ports():
    try:
        import serial.tools.list_ports
        ports = list(serial.tools.list_ports.comports())
        if not ports:
            print("No serial ports found.")
        for p in ports:
            print(f"  {p.device:<30} {p.description}")
    except ImportError:
        print("pyserial not installed. Run: pip install pyserial")


def main():
    parser = argparse.ArgumentParser(description="Steering angle overlay for GTBikeV")
    parser.add_argument(
        "--mode", choices=["ble", "serial"], default="ble",
        help="Connection mode: 'ble' (default) or 'serial' (USB cable)"
    )
    parser.add_argument(
        "--port", default=None,
        help="Serial port to use (serial mode only). Auto-detected if omitted."
    )
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
        _list_ports()
        return

    if args.mode == "serial":
        t = threading.Thread(
            target=serial_thread, args=(args.port, args.baud), daemon=True
        )
    else:
        t = threading.Thread(target=ble_thread, daemon=True)

    t.start()

    root = tk.Tk()
    app = OverlayApp(root, mode=args.mode)
    root.protocol("WM_DELETE_WINDOW", app._on_close)
    root.mainloop()

    stop_event.set()


if __name__ == "__main__":
    main()
