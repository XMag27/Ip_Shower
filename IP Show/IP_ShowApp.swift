import SwiftUI

@main
struct IP_ShowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView().background(Color.clear).hidden() // O simplemente elimínalo completamente
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var ipAddressItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "IP: \(getIPAddress() ?? "Unknown")"
    }

    func getIPAddress() -> String? {
        let interfaceName = "utun6" // Nombre de la interfaz tun4
        var address: String?

        // Create a socket
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }

        // Iterate through interfaces
        var ptr = ifaddr
        while let interface = ptr?.pointee {
            let flags = Int32(interface.ifa_flags)
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) && flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK) == (IFF_UP | IFF_RUNNING) {
                if let name = interface.ifa_name, String(cString: name) == interfaceName {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            ptr = interface.ifa_next
        }

        return address
    }
}
