import Cocoa

class Window: UI {
    let application: Application
    let index: Int
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
    var frame: CGRect {
        CGRect(origin: position, size: size)
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
        let frame = CGRect(origin: position, size: size)
        if let index = screens.firstIndex(where: { $0.frame.contains(frame.flipped(in: $0)) }) {
            print("============window==============")
            print("\(self) \(frame) is in \(screens[index])")
            print("\(self) \(frame.flipped(in: screens[index])) is in \(screens[index])")
            print("================================")
            return index
        }
        if let index = screens.firstIndex(where: { $0.frame.contains(frame.flipped(in: $0).center) }) {
            print("============window==============")
            print("\(self) \(frame) is in \(screens[index])")
            print("\(self) \(frame.flipped(in: screens[index])) is in \(screens[index])")
            print("================================")
            return index
        }
        let distances = screens.map { abs($0.frame.center.distance(to: frame.center)) }
        let closest = distances.min()
        return distances.firstIndex { $0 == closest }!
    }
    var description: String {
        application.description + ":\(index)"
    }

    init(_ application: Application, _ window: AXUIElement, _ i: Int) {
        self.application = application
        interface = window
        index = i
    }
    func focus() {
        application.activate()
        AXUIElementSetAttributeValue(interface, kAXMainAttribute as CFString, kCFBooleanTrue)
        print("============focus==============")
        print(self)
        print("===============================")
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

extension Window {
    func isPrior(to w: Window) -> Bool {
        position.x < w.position.x ||
        (position.x == w.position.x && position.y < w.position.y) ||
        (position.x == w.position.x && position.y == w.position.y && size.width < w.size.width) ||
        (position.x == w.position.x && position.y == w.position.y && size.width == w.size.width && w.size.height < w.size.height) ||
        (position.x == w.position.x && position.y == w.position.y && size.width == w.size.width && size.height == w.size.height && description < w.description)
    }
}

