import Cocoa
import AppKit

func getAllWindows(in screen: Screen) -> [Window] {
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
    let infoList = windowsListInfo as! [[String:Any]]
    let visibleWindows = infoList.filter {
        $0["kCGWindowLayer"] as! Int == 0
    }.map {
        $0["kCGWindowOwnerPID"] as! Int32
    }
    let pids = Array(Set(visibleWindows))
    let applications = pids.map { Application($0) }
    var windows = applications.flatMap { $0.windows }.filter { window in window.screen == screen.index }

    windows.sort { (first, second) in
        let origin = [first.position, second.position]
        return origin[0].x < origin[1].x || (origin[0].x == origin[1].x && origin[0].y < origin[1].y)
    }
    return windows
}

class Screen: CustomStringConvertible {
    private let screen: NSScreen
    let description: String
    let index: Int
    var frame: CGRect { screen.frame }
    var position: CGPoint { frame.origin }
    var size: CGSize { CGSize(width: frame.width, height: frame.height) }
    var windows: [Window] { getAllWindows(in: self) }

    init(_ screen: NSScreen, _ i: Int) {
        self.screen = screen
        description = screen.localizedName
        index = i
    }
    func focusNext() {
        let windows = self.windows
        let last = windows.count - 1
        let focus = windows.firstIndex{ $0.isFocused }!
        windows[focus < last ? focus + 1 : 0].focus()
    }
    func focusPrevious() {
        let windows = self.windows
        let focus = windows.firstIndex{ $0.isFocused }!
        windows[0 < focus ? focus - 1 : windows.count - 1].focus()
    }
}

class Application: CustomStringConvertible {
    let pid: Int32
    let application: NSRunningApplication
    let description: String
    var windows: [Window] = []
    var isActive: Bool {
        application.isActive
    }

    init(_ pid: Int32) {
        var windows: CFArray?
        let application = AXUIElementCreateApplication(pid)

        self.pid = pid
        self.application = NSWorkspace.shared.runningApplications.first { $0.processIdentifier == pid }!
        self.description = self.application.localizedName ?? ""
        AXUIElementCopyAttributeValues(application, kAXWindowsAttribute as CFString, 0, Int.max, &windows)
        if let windows = windows as? [AXUIElement] {
            self.windows = windows.map { Window(self, $0) }
        }
    }
    func activate() {
        if !isActive {
            application.activate(options: [.activateIgnoringOtherApps])
        }
    }
}

class Window: CustomStringConvertible {
    let application: Application
    var window: AXUIElement
    var position: CGPoint = .zero
    var size: CGSize = .zero
    var isMain: Bool {
        var isMain: CFTypeRef?

        AXUIElementCopyAttributeValue(window, kAXMainAttribute as CFString, &isMain)
        return isMain as! Bool
    }
    var isFocused: Bool { application.isActive && isMain }
    var screen: Int {
        screens.firstIndex { NSPointInRect(position as NSPoint, $0.frame) }!
    }
    var description: String {
        application.description
    }

    init(_ application: Application, _ window: AXUIElement) {
        var position: CFTypeRef?
        var size: CFTypeRef?

        self.application = application
        self.window = window
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &position)
        AXValueGetValue(position as! AXValue, .cgPoint, &self.position)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &size)
        AXValueGetValue(size as! AXValue, .cgSize, &self.size)
    }
    func focus() {
        AXUIElementPerformAction(self.window, kAXRaiseAction as CFString)
        application.activate()
        print(self)
    }
}

func getAllScreens() -> [Screen] {
    NSScreen.screens.sorted { (first, second) in
        let origin = [first.frame.origin, second.frame.origin]
        return origin[0].x < origin[1].x || (origin[0].x == origin[1].x && origin[0].y < origin[1].y)
    }.enumerated().map { (i, screen) in Screen(screen, i) }
}

let screens = getAllScreens()
func execute() {
    //for screen in screens {
    //    print(screen)
    //    for window in screen.windows {
    //        sleep(1)
    //        window.focus()
    //    }
    //}
    print(screens)
}
