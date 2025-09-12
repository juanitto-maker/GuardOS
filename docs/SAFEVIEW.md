# SAFEVIEW — GuardOS Secure Viewer

**SafeView** is GuardOS’s hardened viewer for untrusted content: PDFs, images, Office documents (planned). It isolates file rendering in a strict, non-networked, sandboxed environment.

> "If it came from the internet, it should never execute."

---

## 🧱 Purpose

SafeView prevents:
- Embedded PDF scripts or trackers from executing
- Network leaks (image viewers phoning home)
- File-based malware gaining initial foothold

It's the default handler for anything:
- downloaded from the web
- received via USB
- marked suspicious by Aegis

---

## 🔐 Threat Model

| Attack Vector              | SafeView Response |
|---------------------------|-------------------|
| Malicious PDF (JavaScript)| Render as raster (no JS, no fonts) |
| Auto-loading remote images| Blocked; no network stack |
| Scripted Office macros    | Open as plaintext (future); macro execution blocked |
| Exploits via preview      | Viewer runs in sandboxed namespace |
| User tricked into editing | View-only mode; no editing tools |

---

## ⚙️ Behavior

| Action | Result |
|--------|--------|
| Open web-downloaded PDF | Launched via SafeView |
| View USB JPEG | Opened in no-network sandbox |
| Double-click `.docx` (future) | Launch read-only parser (no macros) |
| Attempt to copy/move opened file | Warns user + logs via Aegis |
| Launch viewer directly from shell | Logs input path; warns if file is not isolated |

---

## 🧪 Implementation

**v0 (GuardOS 0.4)**
- CLI tool: `safeview /path/to/file`
- Flatpak or bwrap sandbox
- Uses `pdftoppm`, `imagemagick`, or GTK PDF/image widget
- View-only, no printing

**v1+ (Post-1.0):**
- GUI wrapper with drag-drop support
- Custom thumbnailer with preview risk rating
- Optional micro-VM isolation for `.doc` / `.xls`

---

## 📂 File Flow

1. File enters system (download/USB)
2. Marked by policy as `untrusted`
3. Default opener becomes SafeView (`xdg-open` hook)
4. Viewer launches in locked namespace:
   - No network, IPC, or device access
   - Temp read-only copy created

---

## 📜 Logs & Forensics

- All launches of SafeView are logged by Aegis
- Log includes: timestamp, user, file path, MIME type, verdict
- SafeView exit codes: `0` clean view, `2` malformed, `9` blocked

---

## 🧭 User Guidance

- “Open with SafeView” context menu for USB files
- `safeview` CLI warns on improper usage
- App help explains what’s disabled and why

---

## 🔒 Privacy

- No telemetry, tracking, or usage upload
- No internet access inside SafeView viewer process
- All operations are local; file is not modified

---

## 🔜 Future Roadmap

| Feature | Planned Milestone |
|---------|--------------------|
| GUI drag-drop tool | v1.0 |
| Micro-VM fallback for office files | v2.0 |
| Aegis scoring integration | v1.0+ |
| Network-linked previews (e.g. IPFS) | explicitly blocked by default |

---

See also:
- [`docs/USB_QUARANTINE.md`](./USB_QUARANTINE.md)
- [`docs/AEGIS.md`](./AEGIS.md)
- [`ROADMAP.md`](../ROADMAP.md)
