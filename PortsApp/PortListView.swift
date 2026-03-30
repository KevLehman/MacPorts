import SwiftUI
import AppKit

struct PortListView: View {
    @ObservedObject var scanner: PortScanner
    @State private var searchText = ""
    @State private var confirmKill: PortInfo? = nil
    @State private var copiedPort: Int? = nil
    @State private var hoveredPort: UUID? = nil

    var filteredPorts: [PortInfo] {
        if searchText.isEmpty { return scanner.ports }
        return scanner.ports.filter {
            $0.processName.localizedCaseInsensitiveContains(searchText) ||
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            String($0.port).contains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            searchBar
            Divider()
            portList
        }
        .frame(width: 420, height: 480)
        .onAppear { scanner.scan() }
    }

    private var header: some View {
        HStack {
            Text("Open Ports")
                .font(.headline)
            Spacer()
            Text("\(scanner.ports.count) ports")
                .font(.caption)
                .foregroundColor(.secondary)
            Button(action: { scanner.scan() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderless)
            .disabled(scanner.isScanning)
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
            TextField("Filter by port or process...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var portList: some View {
        Group {
            if scanner.isScanning && scanner.ports.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Scanning ports...")
                        .font(.caption)
                    Spacer()
                }
            } else if filteredPorts.isEmpty {
                VStack {
                    Spacer()
                    Text("No open ports found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredPorts) { port in
                            portRow(port)
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }

    private func rowBackground(for info: PortInfo) -> Color {
        if info.isDocker {
            return Color.blue.opacity(0.06)
        } else if info.isSystemPort {
            return Color.orange.opacity(0.06)
        } else {
            return Color.clear
        }
    }

    private func copyToClipboard(_ info: PortInfo) {
        let text = "localhost:\(info.port)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copiedPort = info.port
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedPort == info.port { copiedPort = nil }
        }
    }

    private func openInBrowser(_ info: PortInfo) {
        let scheme = info.port == 443 || info.port == 8443 || info.port == 18443 ? "https" : "http"
        if let url = URL(string: "\(scheme)://localhost:\(info.port)") {
            NSWorkspace.shared.open(url)
        }
    }

    @ViewBuilder
    private func portRow(_ info: PortInfo) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                confirmKill = info
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.borderless)
            .help("Kill process \(info.pid)")
            .alert(item: $confirmKill) { portInfo in
                Alert(
                    title: Text("Kill Process?"),
                    message: Text("Kill \"\(portInfo.processName)\" (PID \(String(portInfo.pid))) on port \(String(portInfo.port))?"),
                    primaryButton: .destructive(Text("Kill")) {
                        scanner.killProcess(pid: portInfo.pid)
                    },
                    secondaryButton: .cancel()
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(":\(String(info.port))")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    Text(info.protocol_)
                        .font(.system(size: 9, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(3)
                    if info.isDocker {
                        Text("docker")
                            .font(.system(size: 9, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(3)
                    }
                    if info.isSystemPort {
                        Text("system")
                            .font(.system(size: 9, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(3)
                    }
                }
                HStack(spacing: 4) {
                    Text("PID \(String(info.pid))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.7))
                    Text(info.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if info.hasParentChain {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.turn.up.right")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text(info.parentChain.map { "\($0.name)" }.joined(separator: " > "))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            if copiedPort == info.port {
                Text("Copied!")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.green)
            }

            if info.isHttpLikely {
                Button(action: { openInBrowser(info) }) {
                    Image(systemName: "globe")
                        .font(.system(size: 11))
                        .foregroundColor(.accentColor.opacity(0.8))
                }
                .buttonStyle(.borderless)
                .help("Open in browser")
            }

            Button(action: { copyToClipboard(info) }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(.borderless)
            .help("Copy localhost:\(info.port)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(rowBackground(for: info))
        .contentShape(Rectangle())
        .onHover { hovering in
            hoveredPort = hovering ? info.id : nil
        }
        if hoveredPort == info.id, let cmd = info.fullCommand {
            Text(cmd)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.7))
                .lineLimit(2)
                .padding(.horizontal, 44)
                .padding(.bottom, 6)
                .transition(.opacity)
        }
    }
}
