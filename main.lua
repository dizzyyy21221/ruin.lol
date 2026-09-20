import sys
import os
import time
import uuid
import hashlib
import platform
import secrets
import threading
import subprocess
import tkinter as tk
from pathlib import Path

import requests

try:
    from PIL import Image, ImageTk, ImageSequence
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

try:
    import winsound
    HAS_WINSOUND = True
except ImportError:
    HAS_WINSOUND = False


# ============================================================
# CONFIG
# ============================================================

KEYAUTH_NAME    = "Lwttlepaws's Application"
KEYAUTH_OWNER   = "ml98P2lo7r"
KEYAUTH_SECRET  = ""
KEYAUTH_VERSION = "1.0"
KEYAUTH_API     = "https://keyauth.win/api/1.3/"

CHEAT_LUA = r'''
loadstring(game:HttpGet("https://raw.githubusercontent.com/dizzyyy21221/roblox-cheat-lua/refs/heads/main/main.lua"))()
'''

WIN_W = 800
WIN_H = 500

BG = "#000000"
WHITE = "#FFFFFF"
GREY = "#999999"
CREDIT_COL = "#AAAAAA"
GREY_DARK = "#444444"
INPUT_BG = "#1A1A1A"

FONT = "Segoe UI"

LOGO_GIF   = "logo.gif"
AUDIO_FILE = "startup.wav"
AUDIO_LOOP = False

XENO_EXE      = Path(os.environ["APPDATA"]) / "Xeno" / "Xeno.exe"
XENO_AUTOEXEC = Path(os.environ["LOCALAPPDATA"]) / "Xeno" / "autoexec"


# ============================================================
# TIMING
# ============================================================

BOOT_FADE_IN_MS  = 800
BOOT_HOLD_MS     = 500
BOOT_FADE_OUT_MS = 700
MENU_FADE_IN_MS  = 500
FRAME_MS         = 16

CHEAT_CLEANUP_DELAY = 15


# ============================================================
# RESOURCES
# ============================================================

def resource_path(name):
    base = getattr(sys, "_MEIPASS", None)
    if base:
        return Path(base) / name
    return Path(__file__).resolve().parent / name


# ============================================================
# AUDIO
# ============================================================

def play_audio():
    if not HAS_WINSOUND:
        return
    path = resource_path(AUDIO_FILE)
    if not path.exists():
        return
    try:
        winsound.PlaySound(None, winsound.SND_PURGE)
        flags = winsound.SND_FILENAME | winsound.SND_ASYNC
        if AUDIO_LOOP:
            flags |= winsound.SND_LOOP
        winsound.PlaySound(str(path), flags)
    except Exception:
        pass


def stop_audio():
    if not HAS_WINSOUND:
        return
    try:
        winsound.PlaySound(None, winsound.SND_PURGE)
    except Exception:
        pass


# ============================================================
# HWID
# ============================================================

def get_hwid():
    parts = [str(uuid.getnode())]
    try:
        out = subprocess.check_output(
            "wmic csproduct get uuid",
            shell=True, text=True, stderr=subprocess.DEVNULL,
            creationflags=subprocess.CREATE_NO_WINDOW,
        )
        lines = [l.strip() for l in out.splitlines() if l.strip()]
        if len(lines) >= 2:
            parts.append(lines[1])
    except Exception:
        pass
    parts.append(platform.node())
    return hashlib.sha256("|".join(parts).encode()).hexdigest()


# ============================================================
# KEYAUTH
# ============================================================

_SESSION_ID = None


def _api(params):
    data = {
        "name": KEYAUTH_NAME,
        "ownerid": KEYAUTH_OWNER,
        "version": KEYAUTH_VERSION,
    }
    if KEYAUTH_SECRET:
        data["secret"] = KEYAUTH_SECRET
    if _SESSION_ID and params.get("type") != "init":
        data["sessionid"] = _SESSION_ID
    data.update(params)

    try:
        r = requests.post(KEYAUTH_API, data=data, timeout=10)
        if r.text.strip() == "KeyAuth_Invalid":
            return {"success": False, "message": "invalid credentials"}
        return r.json()
    except Exception as e:
        return {"success": False, "message": str(e)}


def auth_init():
    global _SESSION_ID
    res = _api({"type": "init"})
    if res.get("success"):
        _SESSION_ID = res.get("sessionid")
        return True, "ok"
    return False, res.get("message", "init failed")


def auth_login(key, hwid):
    if not _SESSION_ID:
        return False, "no session"
    res = _api({"type": "license", "key": key, "hwid": hwid})
    if res.get("success"):
        return True, "accepted"
    return False, res.get("message", "invalid key")


# ============================================================
# ROBLOX / XENO / CHEAT
# ============================================================

def is_process_running(name):
    try:
        result = subprocess.run(
            ["tasklist", "/FI", f"IMAGENAME eq {name}", "/NH"],
            capture_output=True, text=True,
            creationflags=subprocess.CREATE_NO_WINDOW,
        )
        return name.lower() in result.stdout.lower()
    except Exception:
        return False


def wipe_autoexec_folder():
    """Delete every .lua file in the Xeno autoexec folder."""
    try:
        if not XENO_AUTOEXEC.exists():
            return
        for f in XENO_AUTOEXEC.iterdir():
            if f.is_file() and f.suffix == ".lua":
                try:
                    f.write_text("--\n", encoding="utf-8")
                    f.unlink()
                except Exception:
                    pass
    except Exception:
        pass


def cleanup_autoexec_later(dest: Path):
    """Wait, wipe the specific file, stop music."""
    time.sleep(CHEAT_CLEANUP_DELAY)
    try:
        if dest.exists():
            try:
                dest.write_text("--\n", encoding="utf-8")
            except Exception:
                pass
            try:
                dest.unlink()
            except Exception:
                pass
    except Exception:
        pass
    stop_audio()


def launch_all():
    if not XENO_EXE.is_file():
        return False, "xeno not found"

    # Wipe any leftovers from previous runs
    wipe_autoexec_folder()

    # 1. Open Roblox
    if not is_process_running("RobloxPlayerBeta.exe"):
        try:
            os.startfile("roblox://")
        except Exception as e:
            return False, f"roblox launch failed: {e}"

        deadline = time.time() + 30
        while time.time() < deadline:
            if is_process_running("RobloxPlayerBeta.exe"):
                break
            time.sleep(0.4)

    # 2. Write cheat with random filename
    random_name = secrets.token_hex(8) + ".lua"
    dest = XENO_AUTOEXEC / random_name
    try:
        XENO_AUTOEXEC.mkdir(parents=True, exist_ok=True)
        dest.write_text(CHEAT_LUA.strip() + "\n", encoding="utf-8")
    except Exception as e:
        return False, f"autoexec write failed: {e}"

    # 3. Open Xeno
    if not is_process_running("Xeno.exe"):
        try:
            subprocess.Popen([str(XENO_EXE)])
        except Exception as e:
            return False, f"xeno launch failed: {e}"

    # 4. Schedule cleanup + stop music (non-daemon so close() can wait)
    threading.Thread(
        target=cleanup_autoexec_later,
        args=(dest,),
        daemon=False,
        name="cheat_cleanup",
    ).start()

    return True, "injected. please make sure you have auto inject on in xeno."


# ============================================================
# BACKGROUND GIF
# ============================================================

class BackgroundGif:
    def __init__(self, canvas, path):
        self.canvas = canvas
        self.frames = []
        self.durations = []
        self.index = 0
        self.running = False
        self.after_id = None
        self.image_id = None

        if not HAS_PIL:
            return

        path = Path(path)
        if not path.exists():
            return

        try:
            image = Image.open(path)
            if getattr(image, "is_animated", False):
                frames = ImageSequence.Iterator(image)
            else:
                frames = [image]

            for frame in frames:
                duration = frame.info.get("duration", 100)
                frame = frame.convert("RGB")

                ratio = frame.width / frame.height
                target = WIN_W / WIN_H

                if ratio > target:
                    new_height = frame.height
                    new_width = int(new_height * target)
                    left = (frame.width - new_width) // 2
                    frame = frame.crop((left, 0, left + new_width, new_height))
                else:
                    new_width = frame.width
                    new_height = int(new_width / target)
                    top = (frame.height - new_height) // 2
                    frame = frame.crop((0, top, new_width, top + new_height))

                frame = frame.resize((WIN_W, WIN_H), Image.LANCZOS)
                self.frames.append(ImageTk.PhotoImage(frame))
                self.durations.append(max(30, duration))
        except Exception:
            self.frames.clear()
            self.durations.clear()

    def start(self):
        if not self.frames:
            return
        if self.image_id is None:
            self.image_id = self.canvas.create_image(0, 0, anchor="nw", image=self.frames[0])
            self.canvas.tag_lower(self.image_id)
        self.running = True
        self.tick()

    def tick(self):
        if not self.running or not self.frames:
            return
        frame = self.frames[self.index]
        self.canvas.itemconfig(self.image_id, image=frame)
        self.canvas.image = frame
        delay = self.durations[self.index]
        self.index = (self.index + 1) % len(self.frames)
        self.after_id = self.canvas.after(delay, self.tick)

    def pause(self):
        self.running = False
        if self.after_id is not None:
            try:
                self.canvas.after_cancel(self.after_id)
            except Exception:
                pass
            self.after_id = None

    def stop(self):
        self.pause()


# ============================================================
# MAIN APP
# ============================================================

class App(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("GRABB.VIP")
        self.configure(bg=BG)
        self.resizable(False, False)
        self.center()

        self.is_minimized = False
        self.startup_finished = False
        self.hwid = get_hwid()

        self.canvas = tk.Canvas(
            self, width=WIN_W, height=WIN_H, bg=BG, highlightthickness=0,
        )
        self.canvas.pack()

        self.menu_open = False

        self.bg_gif = BackgroundGif(self.canvas, resource_path(LOGO_GIF))

        self.build_ui()

        self.bg_gif.start()
        self.bg_gif.pause()

        # Wipe any stale files the moment the launcher opens
        wipe_autoexec_folder()

        threading.Thread(target=self.init_auth, daemon=True).start()

        self.after(50, self.start)

        self.protocol("WM_DELETE_WINDOW", self.close)
        self.bind("<Unmap>", self.on_minimize)
        self.bind("<Map>", self.on_restore)

    def center(self):
        self.update_idletasks()
        x = (self.winfo_screenwidth() - WIN_W) // 2
        y = (self.winfo_screenheight() - WIN_H) // 2
        self.geometry(f"{WIN_W}x{WIN_H}+{x}+{y}")

    def init_auth(self):
        ok, msg = auth_init()
        if not ok:
            self.after(0, lambda: self.set_status(f"auth error: {msg}", WHITE))

    # ========================================================
    # UI
    # ========================================================

    def build_ui(self):
        self.boot_overlay = self.canvas.create_rectangle(
            0, 0, WIN_W, WIN_H,
            fill="#000000", outline="",
        )

        self.splash_logo = self.canvas.create_text(
            WIN_W // 2, WIN_H // 2,
            text="GRABB.VIP",
            fill="#000000",
            font=(FONT, 42, "bold"),
            anchor="center",
        )

        self.header_id = self.canvas.create_text(
            55, 70,
            text="GRABB.VIP",
            fill=WHITE,
            font=(FONT, 30, "bold"),
            anchor="w",
            state="hidden",
        )

        self.subtitle_id = self.canvas.create_text(
            57, 101,
            text="launcher",
            fill=GREY,
            font=(FONT, 9),
            anchor="w",
            state="hidden",
        )

        self.license_id = self.canvas.create_text(
            55, 165,
            text="LICENSE KEY",
            fill=WHITE,
            font=(FONT, 10),
            anchor="w",
            state="hidden",
        )

        self.key_entry = tk.Entry(
            self,
            font=(FONT, 11),
            bg=INPUT_BG, fg=WHITE,
            insertbackground=WHITE,
            relief="flat", bd=0,
            highlightthickness=1,
            highlightbackground=GREY_DARK,
            highlightcolor=WHITE,
            justify="left",
        )

        self.entry_id = self.canvas.create_window(
            55, 195, anchor="nw",
            window=self.key_entry,
            width=300, height=36,
            state="hidden",
        )
        self.key_entry.bind("<Return>", lambda _: self.login())

        self.login_button = tk.Button(
            self,
            text="Login",
            font=(FONT, 11, "bold"),
            fg=BG, bg=WHITE,
            activebackground="#CCCCCC", activeforeground=BG,
            relief="flat", bd=0, cursor="hand2",
            command=self.login,
        )

        self.login_button_id = self.canvas.create_window(
            55, 250, anchor="nw",
            window=self.login_button,
            width=300, height=42,
            state="hidden",
        )

        self.status_id = self.canvas.create_text(
            55, 320,
            text="",
            fill=GREY,
            font=(FONT, 9),
            anchor="w",
            state="hidden",
        )

        self.credit_id = self.canvas.create_text(
            55, 350,
            text="made by lew aka lwttlepaws on dc",
            fill=CREDIT_COL,
            font=(FONT, 9),
            anchor="w",
            state="hidden",
        )

        self.launch_button = tk.Button(
            self,
            text="Open",
            font=(FONT, 11, "bold"),
            fg=BG, bg=WHITE,
            activebackground="#CCCCCC", activeforeground=BG,
            relief="flat", bd=0, cursor="hand2",
            command=self.open_launcher,
        )

        self.launch_button_id = self.canvas.create_window(
            55, 195, anchor="nw",
            window=self.launch_button,
            width=300, height=44,
            state="hidden",
        )

        self.quit_button = tk.Button(
            self,
            text="Quit",
            font=(FONT, 11),
            fg=WHITE, bg=INPUT_BG,
            activebackground="#333333", activeforeground=WHITE,
            relief="flat", bd=0, cursor="hand2",
            command=self.close,
        )

        self.quit_button_id = self.canvas.create_window(
            55, 250, anchor="nw",
            window=self.quit_button,
            width=300, height=42,
            state="hidden",
        )

        self.menu_status_id = self.canvas.create_text(
            55, 320,
            text="",
            fill=GREY,
            font=(FONT, 9),
            anchor="w",
            state="hidden",
        )

    # ========================================================
    # BOOT ANIMATION
    # ========================================================

    def start(self):
        play_audio()

        self.canvas.itemconfig(self.splash_logo, fill="#000000")

        self.canvas.tag_raise(self.boot_overlay)
        self.canvas.tag_raise(self.splash_logo)

        self.after(120, self._begin_fade_in)

    def _begin_fade_in(self):
        self._fade_start = time.time()
        self._schedule_fade_in()

    def _schedule_fade_in(self):
        elapsed_ms = (time.time() - self._fade_start) * 1000
        t = min(1.0, elapsed_ms / BOOT_FADE_IN_MS)
        eased = 1 - (1 - t) ** 3
        value = int(eased * 255)
        color = f"#{value:02x}{value:02x}{value:02x}"
        self.canvas.itemconfig(self.splash_logo, fill=color)

        if t < 1.0:
            self.after(FRAME_MS, self._schedule_fade_in)
        else:
            self.after(BOOT_HOLD_MS, self._begin_fade_out)

    def _begin_fade_out(self):
        self._fade_out_start = time.time()
        self._schedule_fade_out()

    def _schedule_fade_out(self):
        import math
        elapsed_ms = (time.time() - self._fade_out_start) * 1000
        t = min(1.0, elapsed_ms / BOOT_FADE_OUT_MS)
        eased = -(math.cos(math.pi * t) - 1) / 2
        value = int((1 - eased) * 255)
        color = f"#{value:02x}{value:02x}{value:02x}"
        self.canvas.itemconfig(self.splash_logo, fill=color)

        if t < 1.0:
            self.after(FRAME_MS, self._schedule_fade_out)
        else:
            self.canvas.itemconfig(self.splash_logo, state="hidden")
            self.canvas.delete(self.boot_overlay)
            self.boot_overlay = None

            self.bg_gif.start()
            self._begin_menu_fade()

    def _begin_menu_fade(self):
        self._menu_alpha_start = time.time()
        self._schedule_menu_fade()

    def _schedule_menu_fade(self):
        elapsed_ms = (time.time() - self._menu_alpha_start) * 1000
        t = min(1.0, elapsed_ms / MENU_FADE_IN_MS)
        eased = 1 - (1 - t) ** 3

        white_val = int(eased * 0xFF)
        grey_val = int(eased * 0x99)
        credit_val = int(eased * 0xAA)

        white_hex = f"#{white_val:02x}{white_val:02x}{white_val:02x}"
        grey_hex = f"#{grey_val:02x}{grey_val:02x}{grey_val:02x}"
        credit_hex = f"#{credit_val:02x}{credit_val:02x}{credit_val:02x}"

        self.canvas.itemconfig(self.header_id, fill=white_hex)
        self.canvas.itemconfig(self.license_id, fill=white_hex)
        self.canvas.itemconfig(self.subtitle_id, fill=grey_hex)
        self.canvas.itemconfig(self.status_id, fill=grey_hex)
        self.canvas.itemconfig(self.credit_id, fill=credit_hex)

        if t < 1.0:
            self.after(FRAME_MS, self._schedule_menu_fade)
        else:
            self.startup_finished = True

            self.canvas.itemconfig(self.header_id, state="normal")
            self.canvas.itemconfig(self.subtitle_id, state="normal")
            self.canvas.itemconfig(self.license_id, state="normal")
            self.canvas.itemconfig(self.status_id, state="normal")
            self.canvas.itemconfig(self.credit_id, state="normal")
            self.canvas.itemconfig(self.entry_id, state="normal")
            self.canvas.itemconfig(self.login_button_id, state="normal")

            self.key_entry.focus()

    # ========================================================
    # LOGIN
    # ========================================================

    def login(self):
        key = self.key_entry.get().strip()

        if not key:
            self.set_status("enter a key", WHITE)
            return

        self.login_button.config(state="disabled", text="Checking...")
        self.set_status("checking...", GREY)

        threading.Thread(target=self.login_thread, args=(key,), daemon=True).start()

    def login_thread(self, key):
        ok, msg = auth_login(key, self.hwid)
        if ok:
            self.after(0, lambda: self.set_status("accepted", WHITE))
            self.after(250, self.show_menu)
        else:
            self.after(0, lambda: self.set_status(
                "invalid key: please enter a valid license",
                WHITE,
            ))
            self.after(0, self.reset_login)

    def reset_login(self):
        self.login_button.config(state="normal", text="Login")
        self.key_entry.delete(0, "end")
        self.key_entry.focus()

    # ========================================================
    # MAIN MENU
    # ========================================================

    def show_menu(self):
        self.menu_open = True

        self.canvas.itemconfig(self.entry_id, state="hidden")
        self.canvas.itemconfig(self.login_button_id, state="hidden")
        self.canvas.itemconfig(self.status_id, state="hidden")

        self.canvas.itemconfig(self.launch_button_id, state="normal")
        self.canvas.itemconfig(self.quit_button_id, state="normal")
        self.canvas.itemconfig(self.menu_status_id, state="normal")

    # ========================================================
    # OPEN
    # ========================================================

    def open_launcher(self):
        self.canvas.itemconfig(
            self.menu_status_id,
            text="launching...",
            fill=GREY,
        )
        self.launch_button.config(state="disabled", text="Launching...")
        threading.Thread(target=self.launch_thread, daemon=True).start()

    def launch_thread(self):
        ok, msg = launch_all()
        if ok:
            self.after(0, lambda: self.canvas.itemconfig(
                self.menu_status_id, text=msg, fill=WHITE))
        else:
            self.after(0, lambda: self.canvas.itemconfig(
                self.menu_status_id, text=f"error: {msg}", fill=WHITE))
        self.after(0, lambda: self.launch_button.config(state="normal", text="Open"))

    # ========================================================
    # MINIMIZE / RESTORE
    # ========================================================

    def on_minimize(self, event=None):
        if self.state() == "iconic":
            self.is_minimized = True
            stop_audio()
            self.bg_gif.pause()

    def on_restore(self, event=None):
        if self.is_minimized:
            self.is_minimized = False
            play_audio()
            self.bg_gif.start()

    # ========================================================
    # STATUS
    # ========================================================

    def set_status(self, text, color=GREY):
        self.canvas.itemconfig(self.status_id, text=text, fill=color)

    # ========================================================
    # CLOSE — wipe autoexec immediately + wait for cleanup
    # ========================================================

    def close(self):
        try:
            self.bg_gif.stop()
        except Exception:
            pass

        # Immediate wipe on close — covers closing before the timer fires
        wipe_autoexec_folder()

        # Wait up to 20s for the delayed cleanup thread to finish
        for t in threading.enumerate():
            if t.name == "cheat_cleanup" and t.is_alive():
                t.join(timeout=20)

        stop_audio()
        self.destroy()


# ============================================================
# RUN
# ============================================================

if __name__ == "__main__":
    app = App()
    app.mainloop()
