#!/usr/bin/env python3
"""Spotlight-style search for rofi (script mode). Started by ~/.local/bin/spotlight ($mod+space).

Lists open windows, herdr agents, apps, quick actions and recent files in one fuzzy-filtered list.
Typed text that matches nothing, confirmed with Enter (or Ctrl+Enter at any time):
  - a sum such as 2^10/3 or sqrt(2)*pi shows the result; Enter on it copies it to the clipboard
  - anything else lists files and folders under ~ whose names match, plus a web search
"""
import ast, glob, html, json, math, mimetypes, operator, os, subprocess, sys, urllib.parse
import xml.etree.ElementTree as ET
from configparser import ConfigParser

HOME = os.path.expanduser("~")
RETV = int(os.environ.get("ROFI_RETV", "0"))
INFO = os.environ.get("ROFI_INFO", "")
ARG = sys.argv[1] if len(sys.argv) > 1 else ""

def emit(text, display, icon=None, info=None, meta=None):
    opts = [("display", display)]
    if icon: opts.append(("icon", icon))
    if info: opts.append(("info", info))
    if meta: opts.append(("meta", meta))
    clean = lambda s: str(s).replace("\n", " ").replace("\0", "").replace("\x1f", " ")
    print(clean(text) + "\0" + "\x1f".join(f"{k}\x1f{clean(v)}" for k, v in opts))

def header(**kv):
    for k, v in kv.items(): print(f"\0{k.replace('_', '-')}\x1f{v}")

def row(title, kind, icon, info, meta="", sub=""):
    tag = html.escape(kind) + (f"  ·  {html.escape(sub)}" if sub else "")
    emit(title, f'{html.escape(title)}   <span alpha="55%" size="82%">{tag}</span>', icon, info, meta)

def detach(args):
    subprocess.Popen(args, start_new_session=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, close_fds=True)

# ---------------- sources ----------------
def windows():
    try: tree = json.loads(subprocess.run(["i3-msg", "-t", "get_tree"], capture_output=True, text=True).stdout)
    except Exception: return
    def walk(n, ws=""):
        if n.get("type") == "workspace": ws = n.get("name", "")
        props = n.get("window_properties") or {}
        cls = props.get("class") or ""
        if n.get("window") and cls.lower() not in ("polybar", "eww"):
            title = n.get("name") or cls
            icon = next((APP_ICONS[k] for k in (cls.lower(), (props.get("instance") or "").lower(), cls.lower().split(".")[-1]) if k in APP_ICONS), cls.lower())
            row(title[:90], "Window", icon, f"win\t{n['id']}", cls, f"workspace {ws}")
        for c in n.get("nodes", []) + n.get("floating_nodes", []): walk(c, ws)
    walk(tree)

def agents():
    try: data = json.loads(subprocess.run(["herdr", "agent", "list"], capture_output=True, text=True, timeout=3).stdout)["result"]["agents"]
    except Exception: return
    order = {"blocked": 0, "done": 1, "working": 2, "idle": 3}
    for a in sorted(data, key=lambda a: order.get(a.get("agent_status"), 9)):
        title = a.get("name") or a.get("terminal_title_stripped") or a.get("cwd", "")
        row(title[:90], "Agent", "utilities-terminal", f"agent\t{a.get('pane_id', '')}", "agent herdr claude " + a.get("cwd", ""),
            f"{a.get('agent_status', '')}, {a.get('cwd', '').replace(HOME, '~')}")

APP_ICONS = {}
def load_apps():
    dirs = [os.path.join(HOME, ".local/share/applications")]
    dirs += [os.path.join(d, "applications") for d in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")]
    dirs += ["/var/lib/snapd/desktop/applications", os.path.join(HOME, ".local/share/flatpak/exports/share/applications"),
             "/var/lib/flatpak/exports/share/applications"]
    seen = set()
    entries = []
    for d in dirs:
        for path in glob.glob(os.path.join(d, "**", "*.desktop"), recursive=True):
            did = os.path.relpath(path, d).replace("/", "-")
            if did in seen: continue
            seen.add(did)
            cp = ConfigParser(interpolation=None, strict=False)
            cp.optionxform = str
            try: cp.read(path, encoding="utf-8")
            except Exception: continue
            if not cp.has_section("Desktop Entry"): continue
            e = cp["Desktop Entry"]
            if e.get("Type") != "Application" or e.get("NoDisplay") == "true" or e.get("Hidden") == "true": continue
            if "i3" in e.get("NotShowIn", "") or (e.get("OnlyShowIn") and "i3" not in e.get("OnlyShowIn", "")): continue
            name = e.get("Name")
            if not name: continue
            # short search terms only: long descriptions and keyword lists made fuzzy matching return junk
            meta = " ".join(filter(None, [e.get("GenericName"), did[:-8].split(".")[-1]]))
            icon = e.get("Icon", "application-x-executable")
            for key in (e.get("StartupWMClass"), did[:-8], name):
                if key: APP_ICONS.setdefault(key.lower(), icon)
            if any(x[0] == name for x in entries): continue
            entries.append((name, icon, path, meta, e.get("GenericName") or ""))
    return sorted(entries, key=lambda x: x[0].lower())

def apps(entries):
    for name, icon, path, meta, generic in entries:
        row(name, "Application", icon, f"app\t{path}", meta, generic)

ACTIONS = [
    ("Toggle dark / light mode", "preferences-desktop-theme", "act\t$HOME/.local/bin/theme-mode toggle", "theme appearance night"),
    ("Quick settings", "preferences-system", "act\t$HOME/.config/eww/scripts/toggle control", "volume brightness bluetooth power profile"),
    ("Wi-Fi networks", "preferences-system", "act\t$HOME/.config/eww/scripts/toggle wifi", "wifi wireless network internet"),
    ("Agents", "utilities-terminal", "act\t$HOME/.config/eww/scripts/toggle agents", "herdr claude agents"),
    ("Calendar", "preferences-system-time", "act\t$HOME/.config/eww/scripts/toggle calendar", "date time"),
    ("Screenshot of an area", "applets-screenshooter", "act\tflameshot gui", "screenshot capture snip"),
    ("Do not disturb on / off", "preferences-system-notifications", "act\tdunstctl set-paused toggle", "notifications silent dnd"),
    ("Lock screen", "system-lock-screen", "act\t$HOME/.local/bin/i3-lock-custom", "lock"),
    ("Power menu", "system-shutdown", "act\t$HOME/.config/rofi/powermenu/type-1/powermenu.sh", "shutdown reboot suspend logout"),
]
def actions():
    for title, icon, info, meta in ACTIONS: row(title, "Action", icon, info, meta)

def file_icon(path):
    if os.path.isdir(path): return "folder"
    mt = mimetypes.guess_type(path)[0] or "text/plain"
    return {"application/pdf": "application-pdf"}.get(mt, mt.split("/")[0] + "-x-generic" if mt.split("/")[0] in ("image", "audio", "video", "text") else "text-x-generic")

def recent():
    try: root = ET.parse(os.path.join(HOME, ".local/share/recently-used.xbel")).getroot()
    except Exception: return
    items = []
    for b in root.findall("bookmark"):
        href = b.get("href", "")
        if href.startswith("file://"):
            p = urllib.parse.unquote(href[7:])
            if os.path.exists(p): items.append((b.get("modified", ""), p))
    for _, p in sorted(items, reverse=True)[:25]:
        row(os.path.basename(p), "Recent file", file_icon(p), f"file\t{p}", "", os.path.dirname(p).replace(HOME, "~"))

# ---------------- calculator ----------------
OPS = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul, ast.Div: operator.truediv,
       ast.FloorDiv: operator.floordiv, ast.Mod: operator.mod, ast.Pow: operator.pow, ast.USub: operator.neg, ast.UAdd: operator.pos}
NAMES = {k: getattr(math, k) for k in ("pi", "e", "tau")}
FUNCS = {k: getattr(math, k) for k in ("sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "log", "log10", "log2", "exp", "floor", "ceil", "factorial")}
FUNCS.update(abs=abs, round=round)
def calc(text):
    expr = text.strip().lstrip("=").replace("^", "**").replace("×", "*").replace("÷", "/").replace(",", ".")
    if not expr or not any(ch.isdigit() for ch in expr): return None
    def ev(n):
        if isinstance(n, ast.Expression): return ev(n.body)
        if isinstance(n, ast.Constant) and isinstance(n.value, (int, float)): return n.value
        if isinstance(n, ast.BinOp) and type(n.op) in OPS:
            l, r = ev(n.left), ev(n.right)
            if isinstance(n.op, ast.Pow) and abs(r) > 1000: raise ValueError("too big")
            return OPS[type(n.op)](l, r)
        if isinstance(n, ast.UnaryOp) and type(n.op) in OPS: return OPS[type(n.op)](ev(n.operand))
        if isinstance(n, ast.Name) and n.id in NAMES: return NAMES[n.id]
        if isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id in FUNCS and not n.keywords:
            return FUNCS[n.func.id](*[ev(a) for a in n.args])
        raise ValueError("unsupported")
    try: v = ev(ast.parse(expr, mode="eval"))
    except Exception: return None
    if isinstance(v, float):
        if v.is_integer() and abs(v) < 1e15: v = int(v)
        else: v = float(f"{v:.12g}")
    return str(v)

# ---------------- dispatch ----------------
if RETV == 1 and INFO:
    kind, _, val = INFO.partition("\t")
    val = val.replace("$HOME", HOME)
    if kind == "app": detach(["gio", "launch", val])
    elif kind == "win": detach(["i3-msg", "-q", f"[con_id={val}] focus"])
    elif kind == "agent": detach([os.path.join(HOME, ".config/eww/scripts/agent-focus"), val])
    elif kind == "act": detach(["sh", "-c", val])
    elif kind == "file": detach(["xdg-open", val])
    elif kind == "web": detach(["xdg-open", "https://duckduckgo.com/?q=" + urllib.parse.quote(val)])
    elif kind == "copy":
        subprocess.run(["xclip", "-selection", "clipboard"], input=val, text=True)
        detach(["notify-send", "-t", "2500", "Copied", val])
    sys.exit(0)

header(prompt="", markup_rows="true")
if RETV == 2 and ARG.strip():
    query = ARG.strip()
    result = calc(query)
    header(keep_filter="true")
    if result is not None:
        header(message=f"{html.escape(query)} = <b>{html.escape(result)}</b>    Enter copies the result")
        emit(result, f'<span size="140%" weight="600">= {html.escape(result)}</span>', "accessories-calculator", f"copy\t{result}", query)
        sys.exit(0)
    skip = [".git", "node_modules", ".cache", ".local/share", ".venv", "venv", ".npm", ".cargo", ".rustup", "snap",
            ".mozilla", ".zen", "go/pkg", "__pycache__", ".bare", ".claude/projects"]
    cmd = ["fdfind", "-i", "--hidden", "--max-depth", "7", "--max-results", "40"]
    for s in skip: cmd += ["--exclude", s]
    try: found = subprocess.run(cmd + ["--", query, HOME], capture_output=True, text=True, timeout=4).stdout.splitlines()
    except Exception: found = []
    header(message=f"{len(found)} file{'s' if len(found) != 1 else ''} under ~ matching <b>{html.escape(query)}</b>, or search the web")
    row(f"Search the web for {query}", "Web", "web-browser", f"web\t{query}", query)
    for p in found:
        p = p.rstrip("/")
        row(os.path.basename(p), "Folder" if os.path.isdir(p) else "File", file_icon(p), f"file\t{p}", query + " " + p, os.path.dirname(p).replace(HOME, "~"))
    sys.exit(0)

header(message="")
APPS = load_apps()
windows(); agents(); actions(); apps(APPS); recent()
