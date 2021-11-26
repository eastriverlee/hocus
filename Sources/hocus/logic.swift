import Cocoa
import AppKit

extension CGRect {
    var midpoint: CGPoint {
       var midpoint = origin 
       midpoint.x += width / 2
       midpoint.y += height / 2
       return midpoint
    }
}
extension String {
    static func <(lhs: String, rhs: String) -> Bool {
        if let lhs = lhs.cString(using: .utf8), let rhs = rhs.cString(using: .utf8) { 
            return strcmp(lhs, rhs) < 0
        }
        return false
    }
    static func >(lhs: String, rhs: String) -> Bool {
        if let lhs = lhs.cString(using: .utf8), let rhs = rhs.cString(using: .utf8) { 
            return strcmp(lhs, rhs) > 0
        }
        return false
    }
}

extension Window {
    func isPrior(to w: Window) -> Bool {
        self.position.x < w.position.x ||
        (self.position.x == w.position.x && self.position.y < w.position.y) ||
        (self.position.x == w.position.x && self.position.y == w.position.y && self.size.width < w.size.width) ||
        (self.position.x == w.position.x && self.position.y == w.position.y && self.size.width == w.size.width && w.size.height < w.size.height) ||
        (self.position.x == w.position.x && self.position.y == w.position.y && self.size.width == w.size.width && self.size.height == w.size.height && self.description < w.description)
    }
}

enum Container: Int {
    case one, two, three, four, five, six, seven, eight, nine, zero
    case h, m, l
    case left, right, up, down
    case next, back
    case top, bottom
    case primary, secondary

    func area(in screen: Screen) -> CGRect {
        var area = screen.frame
        let unit = NSScreen.screens[0].frame.height
        area.origin.y = -(area.height + area.origin.y) + unit + menubarHeight

        print()
        print("unit: \(unit)")
        print("position: \(area.origin)")

        area.size.height -= menubarHeight
        switch self {
        case .next, .back:
            let index = self == .next ? screen.nextIndex : screen.previousIndex
            let screen = screens[index]
            let window = currentWindow()!
            window.fit(in: .five)
            if let fullScreen = screen.windows.first (where: { $0.isFull }) {
                fullScreen.focus()
                toggleFullScreen()
                sleep(1)
                window.focus()
            }
            return Container.five.area(in: screen)

        case .left, .right:
            area.size.width /= 2
            if self == .right { area.origin.x += area.width }

        case .up, .down:
            area.size.height /= 2
            if self == .down { area.origin.y += area.height }

        case .primary, .secondary:
            area.size.width /= 3
            let main = area.width * 2
            if self == .primary { area.size.width = main } else { area.origin.x += main }

        case .top, .bottom:
            area.size.height /= 3
            let main = area.size.height * 2
            if self == .top { area.size.height = main } else { area.origin.y += main }

        case .h, .m, .l:
            area.size.height /= 3
            let row = self == .h ? 0 : self == .m ? 1 : 2
            area.origin.y += CGFloat(row) * area.height

        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            area.size.width /= 3
            area.size.height /= 3
            area.origin.x += CGFloat(rawValue / 3) * area.width
            area.origin.y += CGFloat(rawValue % 3) * area.height

        default:
            break
        }
        print("\(area) in \(screen.frame)[\(screen.index)]")
        print()
        return area
    }
}

extension CGPoint {
    func distance(to p: CGPoint) -> CGFloat {
        sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
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
    let screen: NSScreen
    var frame: CGRect { screen.frame }
    var position: CGPoint { frame.origin }
    var size: CGSize { frame.size }
    var windows: [Window] { getAllWindows(in: self) }

    init(_ screen: NSScreen, _ i: Int) {
        self.screen = screen
        super.init(i, screen.localizedName + ":\(screen.frame)")
    }
    var nextIndex: Int { index < screens.count - 1 ? index + 1 : 0 }
    var previousIndex: Int { 0 < index ? index - 1 : screens.count - 1 }
    @discardableResult
    func next() -> Screen {
        let screens = screens
        var screen = self

        print("--------\(index)------------")
        for _ in 0..<screens.count {
            screen = screens[screen.nextIndex]
            print(screen.windows)
            if let window = screen.windows.first {
                window.focus()
                break
            }
        }
        return screen
    }
    @discardableResult
    func previous() -> Screen {
        let screens = screens
        var screen = self

        print("--------\(index)------------")
        for _ in 0..<screens.count {
            screen = screens[screen.previousIndex]
            print(screen.windows)
            if let window = screen.windows.first {
                window.focus()
                break
            }
        }
        return screen
    }
    @discardableResult
    func nextWindow() -> Window? {
        let windows = self.windows
        guard let focus = windows.firstIndex(where: { $0.isFocused }) else { return nil }
        let window = windows[focus < windows.count - 1 ? focus + 1 : 0]

        print("pick \(window)\(window.position) from \(windows)")
        window.focus()
        return window
    }
    @discardableResult
    func previousWindow() -> Window? {
        let windows = self.windows
        guard let focus = windows.firstIndex(where: { $0.isFocused }) else { return nil }
        let window = windows[0 < focus ? focus - 1 : windows.count - 1]

        print("pick \(window)\(window.position) from \(windows)")
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
        size.height == screens[screen].size.height
    }
    var isFocused: Bool { application.isActive && isMain }
    var screen: Int {
        let screens = screens
        var midpoint = position
        midpoint.x += size.width / 2
        midpoint.y += size.height / 2
        if let index = screens.firstIndex(where: { NSPointInRect(midpoint, $0.frame) }) {
            print("\(self) position: \(position), midpoint: \(midpoint) in \(index)")
            return index
        }
        let distances = screens.map { abs($0.frame.midpoint.distance(to: midpoint)) }
        let closest = distances.min()
        return distances.firstIndex { $0 == closest }!
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
    func fit(in container: Container) {
        let screen = screens[screen]
        var area = container.area(in: screen)
        let position: CFTypeRef = AXValueCreate(.cgPoint, &area.origin)!
        let size: CFTypeRef = AXValueCreate(.cgSize, &area.size)!

        if (area != screen.frame && isFull) || (area == screen.frame && !isFull) { 
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
