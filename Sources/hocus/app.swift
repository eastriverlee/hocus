import Cocoa

enum Keycode: UInt16 {

	// Layout-independent Keys
	// eg.These key codes are always the same key on all layouts.
	case returnKey                 = 0x24
	case enter                     = 0x4C
	case tab                       = 0x30
	case space                     = 0x31
	case delete                    = 0x33
	case escape                    = 0x35
	case command                   = 0x37
	case shift                     = 0x38
	case capsLock                  = 0x39
	case option                    = 0x3A
	case control                   = 0x3B
	case rightShift                = 0x3C
	case rightOption               = 0x3D
	case rightControl              = 0x3E
	case leftArrow                 = 0x7B
	case rightArrow                = 0x7C
	case downArrow                 = 0x7D
	case upArrow                   = 0x7E
	case volumeUp                  = 0x48
	case volumeDown                = 0x49
	case mute                      = 0x4A
	case help                      = 0x72
	case home                      = 0x73
	case pageUp                    = 0x74
	case forwardDelete             = 0x75
	case end                       = 0x77
	case pageDown                  = 0x79
	case function                  = 0x3F
	case f1                        = 0x7A
	case f2                        = 0x78
	case f4                        = 0x76
	case f5                        = 0x60
	case f6                        = 0x61
	case f7                        = 0x62
	case f3                        = 0x63
	case f8                        = 0x64
	case f9                        = 0x65
	case f10                       = 0x6D
	case f11                       = 0x67
	case f12                       = 0x6F
	case f13                       = 0x69
	case f14                       = 0x6B
	case f15                       = 0x71
	case f16                       = 0x6A
	case f17                       = 0x40
	case f18                       = 0x4F
	case f19                       = 0x50
	case f20                       = 0x5A

	// US-ANSI Keyboard Positions
	// eg. These key codes are for the physical key (in any keyboard layout)
	// at the location of the named key in the US-ANSI layout.
	case a                         = 0x00
	case b                         = 0x0B
	case c                         = 0x08
	case d                         = 0x02
	case e                         = 0x0E
	case f                         = 0x03
	case g                         = 0x05
	case h                         = 0x04
	case i                         = 0x22
	case j                         = 0x26
	case k                         = 0x28
	case l                         = 0x25
	case m                         = 0x2E
	case n                         = 0x2D
	case o                         = 0x1F
	case p                         = 0x23
	case q                         = 0x0C
	case r                         = 0x0F
	case s                         = 0x01
	case t                         = 0x11
	case u                         = 0x20
	case v                         = 0x09
	case w                         = 0x0D
	case x                         = 0x07
	case y                         = 0x10
	case z                         = 0x06

	case zero                      = 0x1D
	case one                       = 0x12
	case two                       = 0x13
	case three                     = 0x14
	case four                      = 0x15
	case five                      = 0x17
	case six                       = 0x16
	case seven                     = 0x1A
	case eight                     = 0x1C
	case nine                      = 0x19

	case equals                    = 0x18
	case minus                     = 0x1B
	case semicolon                 = 0x29
	case apostrophe                = 0x27
	case comma                     = 0x2B
	case period                    = 0x2F
	case forwardSlash              = 0x2C
	case backslash                 = 0x2A
	case grave                     = 0x32
	case leftBracket               = 0x21
	case rightBracket              = 0x1E

	case keypadDecimal             = 0x41
	case keypadMultiply            = 0x43
	case keypadPlus                = 0x45
	case keypadClear               = 0x47
	case keypadDivide              = 0x4B
	case keypadMinus               = 0x4E
	case keypadEquals              = 0x51
	case keypad0                   = 0x52
	case keypad1                   = 0x53
	case keypad2                   = 0x54
	case keypad3                   = 0x55
	case keypad4                   = 0x56
	case keypad5                   = 0x57
	case keypad6                   = 0x58
	case keypad7                   = 0x59
	case keypad8                   = 0x5B
	case keypad9                   = 0x5C
}

typealias Modifier = NSEvent.ModifierFlags
extension Modifier {
    func contains(modifier: Modifier) -> Bool {
        self.rawValue | modifier.rawValue != 0
    }
}
private func put(_ modifiers: Modifier, into keys: inout Set<Keycode>) {
    if modifiers.rawValue != 0 {
        if modifiers.contains(.shift) {
            keys.insert(.shift)
        }
//        if modifiers.contains(.function) {
//            keys.insert(.function)
//        }
        if modifiers.contains(.control) {
            keys.insert(.control)
        }
        if modifiers.contains(.command) {
            keys.insert(.command)
        }
        if modifiers.contains(.option) {
            keys.insert(.option)
        }
        if modifiers.contains(.capsLock) {
            keys.insert(.capsLock)
        }
    }
}

class Key: CustomStringConvertible, Equatable {
    let key: Keycode
    let description: String
    var keys: Set<Keycode>
    init(_ event: NSEvent) {
        key = Keycode(rawValue: event.keyCode)!
        keys = [key]
        put(event.modifierFlags, into: &keys)
        description = "\(keys)"
    }
    init(_ key: Keycode, _ modifiers: Set<Keycode>) {
        self.key = key
        keys = modifiers
        keys.insert(key)
        description = "\(keys)"
    }
    static func ==(lhs: Key, rhs: Key) -> Bool {
        lhs.key == rhs.key && lhs.keys == rhs.keys
    }
}

func currentScreenIndex() -> Int {
    currentWindow()?.screen ?? 0
}
func currentScreen() -> Screen {
    screens[currentScreenIndex()]
}
func currentWindow() -> Window? {
    getAllWindows().first { $0.isFocused }
}

var menubarHeight: CGFloat { NSStatusBar.system.thickness }


let modifiers: Set<Keycode> = [.shift, .option, .control]
func execute(_ keycode: Keycode) {
    let key = Key(keycode, modifiers)

    execute(key)
}

func execute(_ key: Key) {
    switch key {

    case Key(.zero, modifiers):
        currentWindow()?.fit(in: .zero)
    case Key(.one, modifiers):
        currentWindow()?.fit(in: .one)
    case Key(.two, modifiers):
        currentWindow()?.fit(in: .two)
    case Key(.three, modifiers):
        currentWindow()?.fit(in: .three)
    case Key(.four, modifiers):
        currentWindow()?.fit(in: .four)
    case Key(.five, modifiers):
        currentWindow()?.fit(in: .five)
    case Key(.six, modifiers):
        currentWindow()?.fit(in: .six)
    case Key(.seven, modifiers):
        currentWindow()?.fit(in: .seven)
    case Key(.eight, modifiers):
        currentWindow()?.fit(in: .eight)
    case Key(.nine, modifiers):
        currentWindow()?.fit(in: .nine)

    case Key(.h, modifiers):
        currentWindow()?.fit(in: .h)
    case Key(.m, modifiers):
        currentWindow()?.fit(in: .m)
    case Key(.l, modifiers):
        currentWindow()?.fit(in: .l)

    case Key(.leftBracket, modifiers):
        currentWindow()?.fit(in: .left)
    case Key(.rightBracket, modifiers):
        currentWindow()?.fit(in: .right)

    case Key(.t, modifiers):
        currentWindow()?.fit(in: .top)
    case Key(.b, modifiers):
        currentWindow()?.fit(in: .bottom)

    case Key(.p, modifiers):
        currentWindow()?.fit(in: .primary)
    case Key(.s, modifiers):
        currentWindow()?.fit(in: .secondary)

    case Key(.u, modifiers):
        currentWindow()?.fit(in: .up)
    case Key(.d, modifiers):
        currentWindow()?.fit(in: .down)

    case Key(.period, modifiers):
        currentWindow()?.fit(in: .next)
    case Key(.comma, modifiers):
        currentWindow()?.fit(in: .back)

    case Key(.upArrow, modifiers):
        currentScreen().previousWindow()
    case Key(.downArrow, modifiers):
        currentScreen().nextWindow()
    case Key(.leftArrow, modifiers):
        currentScreen().previous()
    case Key(.rightArrow, modifiers):
        currentScreen().next()

    case Key(.equals, modifiers):
        toggleFullScreen()

        default: print(key)
    }
}

func listenInput() {
    print(screens)
    NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
        execute(Key(event))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var item: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        let menu = NSMenu(title: "hocus menu")
        item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
		//item.button?.image = {
		//	let image = #imageLiteral(resourceName: "logo")
		//	image.size.width = 18
		//	image.size.height = 18
		//	image.isTemplate = true
		//	return image
		//}()
        item.button?.title = "𝒇"
        item.menu = menu
        menu.addItem(withTitle: "left", action: #selector(AppDelegate.left), keyEquivalent: "[")
        menu.addItem(withTitle: "right", action: #selector(AppDelegate.right), keyEquivalent: "]")
        menu.addItem(withTitle: "fill", action: #selector(AppDelegate.fill), keyEquivalent: "0")
        menu.addItem(withTitle: "quit", action: #selector(AppDelegate.quit), keyEquivalent: "")
        listenInput()
    }
    @objc func left() {
        execute(.leftBracket)
    }
    @objc func right() {
        execute(.rightBracket)
    }
    @objc func fill() {
        execute(.zero)
    }
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
