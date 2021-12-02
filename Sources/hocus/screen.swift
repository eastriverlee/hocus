import Cocoa
import AppKit

extension CGPoint {
    func distance(to p: CGPoint) -> CGFloat {
        sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
    }
}

extension CGRect {
    var center: CGPoint { .init(x: midX, y: midY) }
    func flipped(in screen: Screen) -> CGRect {
        var area = self

        area.origin.y += screen.position.y
        return area
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

enum Container: Int {
    case one, two, three, four, five, six, seven, eight, nine, zero
    case middle
    case left, right, up, down
    case next, back
    case top, bottom
    case primary, secondary

    func area(in screen: Screen) -> CGRect {
        var position = screen.position
        var width = screen.frame.width
        var height = screen.frame.height

        height -= menubarHeight
        switch self {
        case .next, .back:
            let index = self == .next ? screen.nextIndex : screen.previousIndex
            let screen = screens[index]
            let window = currentWindow()!
            window.fit(in: .five)
            if let fullScreen = screen.windows.first(where: { $0.isFull }) {
                fullScreen.focus()
                toggleFullScreen()
                sleep(1)
                window.focus()
            }
            return Container.middle.area(in: screen)

        case .left, .right:
            width /= 2
            if self == .right { position.x += width }

        case .up, .down:
            height /= 2
            if self == .down { position.y += height }

        case .primary, .secondary:
            width /= 3
            let main = width * 2
            if self == .primary { width = main } else { position.x += main }

        case .top, .bottom:
            height /= 3
            let main = height * 2
            if self == .top { height = main } else { position.y += main }

        case .middle:
            let portrait = height > width
            let landscape = height < width
            let side = portrait ? width : height
            position.x += portrait ? 0 : (width - side)/2
            position.y += landscape ? 0 : (height - side)/2
            height = side
            width = side

        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            width /= 3
            height /= 3
            position.x += CGFloat(rawValue / 3) * width
            position.y += CGFloat(rawValue % 3) * height

        default:
            break
        }
        return CGRect(origin: position, size: CGSize(width: width, height: height))
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
    var applications = visibleWindows.map { pid in Application(pid) }
    for application in applications {
        if application.description == "Finder" && !application.windows.isEmpty {
            let biggest = application.windows.map { window in
                (window: window, area: window.size.width * window.size.height)
            }.sorted(by: {$0.area > $1.area})[0].window
            application.windows = application.windows.filter { $0.index != biggest.index }
        }
    }
    var windows = applications.flatMap { $0.windows }
    if let screen = screen {
        windows = windows.filter { window in window.screen == screen.index }
        if windows.first(where:{ $0.isFull }) != nil {
            return windows
        }
    }
    windows.sort { (first, second) in
        return first.isPrior(to: second)
    }
    return windows
}

protocol UI: CustomStringConvertible {
    var index: Int { get }
    var description: String { get }
}

class Screen: UI {
    let screen: NSScreen
    let index: Int
    var frame: CGRect { screen.frame }
    var origin: CGPoint { frame.origin }
    var position: CGPoint {
        var position = origin
        let unit = NSScreen.screens[0].frame.height
        let offset = -(size.height + origin.y) + unit + menubarHeight
        position.y = offset
        return position
    }
    var size: CGSize { frame.size }
    var windows: [Window] { getAllWindows(in: self) }
    var description: String

    init(_ screen: NSScreen, _ i: Int) {
        self.screen = screen
        index = i
        description = screen.localizedName + ":\(screen.frame)"
    }
    var nextIndex: Int { index < screens.count - 1 ? index + 1 : 0 }
    var previousIndex: Int { 0 < index ? index - 1 : screens.count - 1 }
    @discardableResult
    func next() -> Screen {
        let screens = screens
        var screen = self

        for _ in screens {
            screen = screens[screen.nextIndex]
            for window in screen.windows {
                window.focus()
                if window.isFocused { return screen }
            }
        }
        return screen
    }
    @discardableResult
    func previous() -> Screen {
        let screens = screens
        var screen = self

        for _ in screens {
            screen = screens[screen.previousIndex]
            for window in screen.windows {
                window.focus()
                if window.isFocused { return screen }
            }
        }
        return screen
    }
    @discardableResult
    func nextWindow() -> Window? {
        let windows = self.windows
        guard let focus = windows.firstIndex(where: { $0.isFocused }) else { return nil }
        var window = windows[focus]

        for i in 1...windows.count {
            let next = windows.index(focus + i)
            window = windows[next]
            window.focus()
            if window.isFocused {
                print("pick \(window)\(window.position) from \(windows)")
                break
            }
        }
        return window
    }
    @discardableResult
    func previousWindow() -> Window? {
        let windows = self.windows
        guard let focus = windows.firstIndex(where: { $0.isFocused }) else { return nil }
        var window = windows[focus]

        for i in 1...windows.count {
            let previous = windows.index(focus - i)
            window = windows[previous]
            window.focus()
            if window.isFocused {
                print("pick \(window)\(window.position) from \(windows)")
                break
            }
        }
        return window
    }
}
extension Array {
    func index(_ i: Int) -> Int {
        let count = count
        return i >= 0 ? i % count : count - (abs(i) % count) - 1
    }
}

var screens: [Screen] {
    NSScreen.screens.sorted { (first, second) in
        let origin = [first.frame.origin, second.frame.origin]
        return origin[0].x < origin[1].x || (origin[0].x == origin[1].x && origin[0].y < origin[1].y)
    }.enumerated().map { (i, screen) in Screen(screen, i) }
}
