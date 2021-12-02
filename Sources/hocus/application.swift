import Cocoa

class Application: CustomStringConvertible {
    let pid: Int32
    let interface: AXUIElement
    let description: String
    var windows: [Window] = []
    var isActive: Bool {
        var isActive: CFTypeRef?

        AXUIElementCopyAttributeValue(interface, kAXFrontmostAttribute as CFString, &isActive)
        return isActive as! Bool
    }

    init(_ pid: Int32) {
        var windows: CFArray?
        var name: CFTypeRef?

        self.pid = pid
        interface = AXUIElementCreateApplication(pid)
        AXUIElementCopyAttributeValue(interface, kAXTitleAttribute as CFString, &name)
        description = name as? String ?? ""
        AXUIElementCopyAttributeValues(interface, kAXWindowsAttribute as CFString, 0, Int.max, &windows)
        if let windows = windows as? [AXUIElement] {
            self.windows = windows.enumerated().map { (i, window) in Window(self, window, i) }
        }
    }
    func activate() {
        AXUIElementSetAttributeValue(interface, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
        while !isActive { }
    }
}
