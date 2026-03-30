import SwiftUI
import ServiceManagement
import Combine

@main
struct PortsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let scanner = PortScanner()
    private var cancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        registerLaunchAtLogin()
        scanner.scan()
        scanner.startAutoRefresh(interval: 30)

        // Update badge whenever ports change
        cancellable = scanner.$ports
            .receive(on: RunLoop.main)
            .sink { [weak self] ports in
                self?.updateBadge(count: ports.count)
            }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Open Ports")
            button.imagePosition = .imageLeading
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PortListView(scanner: scanner))
    }

    private func updateBadge(count: Int) {
        guard let button = statusItem.button else { return }
        button.title = " \(count)"
    }

    private func registerLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
            // Back to slow background refresh for badge
            scanner.startAutoRefresh(interval: 30)
        } else {
            scanner.scan()
            // Fast refresh while popover is open
            scanner.startAutoRefresh(interval: 5)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
