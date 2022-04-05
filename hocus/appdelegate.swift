//
//  appdelegate.swift
//  hocus
//
//  Created by eastriver lee on 2021/11/30.
//

import Cocoa
import LaunchAtLogin
import ScriptingBridge

let accessibility = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!

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
let modifiers: Set<Keycode> = [.option, .control]
let _modifiers = Modifier([.option, .control])
private let accessibilityGranted = AXIsProcessTrusted()

func execute(_ keycode: Keycode) {
    let key = Key(keycode, modifiers)

    execute(key)
}

extension NSMenu {
    func addItem(withTitle title: String, action: Selector? = nil, key: String = "") {
        let item = addItem(withTitle: title, action: action, keyEquivalent: key)
        item.keyEquivalentModifierMask = _modifiers
    }
    func addItem(withTitle title: String, action: Selector? = nil, key: KeyEquivalent) {
        addItem(withTitle: title, action: action, key: key.string)
    }
    func disableItems() {
        for (i, item) in items.enumerated() {
            if i > 2 {
                item.action = nil
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var item: NSStatusItem!
    let statusBar = NSStatusBar.system
    let menu = NSMenu(title: "hocus menu")

    private func openAccessibility() {
        NSWorkspace.shared.open(accessibility)
    }
    private func makeStatusBarMenu() {
        item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = {
            let image = NSImage(imageLiteralResourceName: "logo")
            image.size.width = 18
            image.size.height = 18
            return image
        }()
        item.menu = menu
        if !accessibilityGranted {
            askToGrantAccessibility()
            let instruction = NSMenuItem()
            instruction.indentationLevel = 1
            instruction.title = "Access Denied"
            menu.addItem(withTitle: "Allow Access", action: #selector(restart))
            menu.addItem(instruction)
            menu.addItem(.separator())
        }
        let launchAtLogin = NSMenuItem(title: "Start hocus at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLogin.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchAtLogin)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Next Screen", action: #selector(nextScreen), key: .rightArrow)
        menu.addItem(withTitle: "Previous Screen", action: #selector(previousScreen), key: .leftArrow)
        menu.addItem(withTitle: "Next Window", action: #selector(nextWindow), key: .downArrow)
        menu.addItem(withTitle: "Previous Window", action: #selector(previousWindow), key: .upArrow)
        menu.addItem(withTitle: "Jump Window", action: #selector(jumpWindow), key: " ")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Move Next", action: #selector(moveToNextScreen), key: ".")
        menu.addItem(withTitle: "Move Prev", action: #selector(moveToPreviousScreen), key: ",")
        menu.addItem(withTitle: "Left", action: #selector(left), key: "[")
        menu.addItem(withTitle: "Right", action: #selector(right), key: "]")
        menu.addItem(withTitle: "Primary", action: #selector(primary), key: "p")
        menu.addItem(withTitle: "Secondary", action: #selector(secondary), key: "s")
        menu.addItem(withTitle: "Top", action: #selector(top), key: "t")
        menu.addItem(withTitle: "Bottom", action: #selector(bottom), key: "b")
        menu.addItem(withTitle: "Middle", action: #selector(middle), key: "m")
        menu.addItem(withTitle: "Fill", action: #selector(fill), key: "0")
        menu.addItem(withTitle: "Toggle Fullscreen", action: #selector(fullscreen), key: "=")
        menu.addItem(withTitle: "1", action: #selector(_1), key: "1")
        menu.addItem(withTitle: "2", action: #selector(_2), key: "2")
        menu.addItem(withTitle: "3", action: #selector(_3), key: "3")
        menu.addItem(withTitle: "4", action: #selector(_4), key: "4")
        menu.addItem(withTitle: "5", action: #selector(_5), key: "5")
        menu.addItem(withTitle: "6", action: #selector(_6), key: "6")
        menu.addItem(withTitle: "7", action: #selector(_7), key: "7")
        menu.addItem(withTitle: "8", action: #selector(_8), key: "8")
        menu.addItem(withTitle: "9", action: #selector(_9), key: "9")
        if !accessibilityGranted {
            menu.disableItems()
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit))
    }
    private func listenInput() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
            execute(Key(event))
        }
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        makeStatusBarMenu()
        if accessibilityGranted {
            listenInput()
            print(getAllWindows())
        }
    }
    @objc func askToGrantAccessibility() {
        openAccessibility()
        let alert = NSAlert()
        alert.messageText = "\"hocus\" will not work until it is quit after selecting the accesibility checkbox"
        alert.informativeText = "To use hocus, select the hocus checkbox in Security & Privacy > Accessibility and reopen."
        alert.addButton(withTitle: "Quit & Reopen")
        alert.addButton(withTitle: "Later")
        let result = alert.runModal()
        
        switch result {
        case .alertFirstButtonReturn: restart()
        default: break
        }
    }
    @objc func left() {
        execute(.leftBracket)
    }
    @objc func right() {
        execute(.rightBracket)
    }
    @objc func primary() {
        execute(.p)
    }
    @objc func secondary() {
        execute(.s)
    }
    @objc func top() {
        execute(.t)
    }
    @objc func bottom() {
        execute(.b)
    }
    @objc func middle() {
        execute(.m)
    }
    @objc func fill() {
        execute(.zero)
    }
    @objc func fullscreen() {
        execute(.equals)
    }
    @objc func nextScreen() {
        execute(.rightArrow)
    }
    @objc func previousScreen() {
        execute(.leftArrow)
    }
    @objc func nextWindow() {
        execute(.downArrow)
    }
    @objc func previousWindow() {
        execute(.upArrow)
    }
    @objc func jumpWindow() {
        execute(.space)
    }
    @objc func moveToNextScreen() {
        execute(.period)
    }
    @objc func moveToPreviousScreen() {
        execute(.comma)
    }
    @objc func _1() {
        execute(.one)
    }
    @objc func _2() {
        execute(.two)
    }
    @objc func _3() {
        execute(.three)
    }
    @objc func _4() {
        execute(.four)
    }
    @objc func _5() {
        execute(.five)
    }
    @objc func _6() {
        execute(.six)
    }
    @objc func _7() {
        execute(.seven)
    }
    @objc func _8() {
        execute(.eight)
    }
    @objc func _9() {
        execute(.nine)
    }
    @objc func quit() {
        NSApp.terminate(self)
    }
    @objc func toggleLaunchAtLogin() {
        LaunchAtLogin.isEnabled.toggle()
        menu.item(at: 0)!.state = LaunchAtLogin.isEnabled ? .on : .off
    }
    @objc func restart(after seconds: TimeInterval = 0.5) -> Never {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        
        NSApp.terminate(self)
        exit(0)
    }
}
