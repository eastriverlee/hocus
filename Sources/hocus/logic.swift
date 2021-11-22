import Cocoa
import AppKit

extension Window {
    func isPrior(to window: Window) -> Bool {
        self.position.x < window.position.x ||
        (self.position.x == window.position.x && self.position.y < window.position.y) ||
        (self.position.x == window.position.x && self.position.y == window.position.y && self.index < self.index)
    }
}

func press(_ key: Keycode, _ modifiers: [CGEventFlags]) {
    let source = CGEventSource(stateID: .hidSystemState)
    let location = CGEventTapLocation.cghidEventTap
    let down = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: true)
    let up = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: false)
    let mask = modifiers.reduce(0) { $0 | $1.rawValue }

    down?.flags = .init(rawValue: mask)
    down?.post(tap: location)
    up?.post(tap: location)
}
func toggleFullScreen() {
    press(.f, [.maskControl, .maskCommand])
}

func getAllWindows(in screen: Screen? = nil) -> [Window] {
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
    let infoList = windowsListInfo as! [[String:Any]]
    var visibleWindows = infoList.filter { $0["kCGWindowLayer"] as! Int == 0 }.map { window in
        window["kCGWindowOwnerPID"] as! Int32
    }
    visibleWindows = Array(Set(visibleWindows))
    let applications = visibleWindows.map { pid in Application(pid) }
    var windows = applications.flatMap { $0.windows }
    if let screen = screen {
        windows = windows.filter { window in window.screen == screen.index }
        if let fullScreen = windows.first(where:{ $0.isFull }) {
            return [fullScreen]
        }
    }
    windows.sort { (first, second) in
        return first.isPrior(to: second)
    }
    return windows
}

class UI: CustomStringConvertible {
    let index: Int
    let description: String
    init(_ i: Int, _ description: String) {
        index = i
        self.description = description
    }
}

class Screen: UI {
    private let screen: NSScreen
    var frame: CGRect { screen.frame }
    var position: CGPoint { frame.origin }
    var size: CGSize { frame.size }
    var windows: [Window] { getAllWindows(in: self) }

    init(_ screen: NSScreen, _ i: Int) {
        self.screen = screen
        super.init(i, screen.localizedName)
    }
    @discardableResult
    func next() -> Screen {
        let screens = screens
        let next = index < screens.count - 1 ? index + 1 : 0
        let screen = screens[next]

        screen.windows.first!.focus()
        return screen
    }
    @discardableResult
    func previous() -> Screen {
        let screens = screens
        let previous = 0 < index ? index - 1 : screens.count - 1
        let screen = screens[previous]

        screen.windows.first!.focus()
        return screen
    }
    @discardableResult
    func focusNext() -> Window {
        let windows = self.windows
        let focus = windows.firstIndex{ $0.isFocused }!
        let window = windows[focus < windows.count - 1 ? focus + 1 : 0]

        window.focus()
        return window
    }
    @discardableResult
    func focusPrevious() -> Window {
        let windows = self.windows
        let focus = windows.firstIndex{ $0.isFocused }!
        let window = windows[0 < focus ? focus - 1 : windows.count - 1]

        window.focus()
        return window
    }
}

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
        description = name as! String
        AXUIElementCopyAttributeValues(interface, kAXWindowsAttribute as CFString, 0, Int.max, &windows)
        if let windows = windows as? [AXUIElement] {
            self.windows = windows.enumerated().map { (i, window) in Window(self, window, i) }
        }
    }
    func activate() {
        AXUIElementSetAttributeValue(interface, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    }
}

class Window: UI {
    let application: Application
    var interface: AXUIElement
    var position: CGPoint {
        var position_: CFTypeRef?
        var position: CGPoint = .zero

        AXUIElementCopyAttributeValue(interface, kAXPositionAttribute as CFString, &position_)
        AXValueGetValue(position_ as! AXValue, .cgPoint, &position)
        return position
    }
    var size: CGSize {
        var size_: CFTypeRef?
        var size: CGSize = .zero
        
        AXUIElementCopyAttributeValue(interface, kAXSizeAttribute as CFString, &size_)
        AXValueGetValue(size_ as! AXValue, .cgSize, &size)
        return size
    }
    var isMain: Bool {
        var isMain: CFTypeRef?

        AXUIElementCopyAttributeValue(interface, kAXMainAttribute as CFString, &isMain)
        return isMain as! Bool
    }
    var isFull: Bool {
        size == screens[screen].size
    }
    var isFocused: Bool { application.isActive && isMain }
    var screen: Int {
        screens.firstIndex { NSPointInRect(position as NSPoint, $0.frame) }!
    }

    init(_ application: Application, _ window: AXUIElement, _ i: Int) {

        self.application = application
        self.interface = window
        super.init(i, application.description + ":\(i)")
    }
    func focus() {
        application.activate()
        while !application.isActive { }
        AXUIElementSetAttributeValue(interface, kAXMainAttribute as CFString, kCFBooleanTrue)
        print(self)
    }
    func fit(in location: inout CGRect) {
        let position: CFTypeRef = AXValueCreate(.cgPoint, &location.origin)!
        let size: CFTypeRef = AXValueCreate(.cgSize, &location.size)!

        if isFull { 
            toggleFullScreen()
            sleep(1)
        }
        AXUIElementSetAttributeValue(interface, kAXPositionAttribute as CFString, position)
        AXUIElementSetAttributeValue(interface, kAXSizeAttribute as CFString, size)
    }
}

var screens: [Screen] {
    NSScreen.screens.sorted { (first, second) in
        let position = [first.frame.origin, second.frame.origin]
        return position[0].x < position[1].x || (position[0].x == position[1].x && position[0].y < position[1].y)
    }.enumerated().map { (i, screen) in Screen(screen, i) }
}
