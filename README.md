# PortsApp

A lightweight macOS menu bar app that shows all open (listening) ports on your machine. Click the icon, see what's running, and kill anything you don't need.

<img width="422" height="481" alt="image" src="https://github.com/user-attachments/assets/75030a25-df7d-462f-be8d-36735445df5c" />

<img width="79" height="29" alt="image" src="https://github.com/user-attachments/assets/322819a6-c6b3-45cc-af40-669721ea2c0e" />


## Features

- **Menu bar icon** with live port count badge
- **Lists all listening TCP/UDP ports** with process name, PID, and local address
- **Kill processes** directly from the UI with a confirmation dialog
- **Docker integration** — resolves `com.docker` processes to their container name and image
- **Process tree** — shows parent process chain (e.g., `node > zsh > Terminal`)
- **Full command on hover** — hover over a row to see the complete command line
- **Copy to clipboard** — copy `localhost:<port>` with one click
- **Open in browser** — quick-launch HTTP-likely ports (3000, 8080, etc.)
- **Search/filter** — filter by port number, process name, or Docker container
- **Color-coded rows** — system ports (orange), Docker ports (blue), app ports (default)
- **Auto-refresh** — updates every 5s while open, every 30s in background
- **Launch at login** — registers itself via macOS `SMAppService`

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+ (included with Xcode Command Line Tools)

## Build & Install

```bash
# Clone the repo
git clone https://github.com/KevLehman/MacPorts.git
cd MacPorts

# Build and create the .app bundle
./build.sh

# Run it
open PortsApp.app

# (Optional) Install to Applications for launch at login
cp -r PortsApp.app /Applications/
```

## Usage

1. After launching, a **network icon** with a port count appears in your menu bar
2. **Click** the icon to open the port list
3. **Hover** over a row to see the full command line
4. **Click the trash icon** to kill a process (with confirmation)
5. **Click the globe icon** to open an HTTP port in your browser
6. **Click the copy icon** to copy `localhost:<port>` to your clipboard
7. Use the **search bar** to filter by port number or process name

## License

MIT

