//
//  key.swift
//  hocus
//
//  Created by eastriver lee on 2022/04/04.
//

import Cocoa

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

    case Key(.m, modifiers):
        currentWindow()?.fit(in: .middle)

    case Key(.k, modifiers): fallthrough
    case Key(.upArrow, modifiers):
        currentScreen().previousWindow()
    case Key(.j, modifiers): fallthrough
    case Key(.downArrow, modifiers):
        currentScreen().nextWindow()
    case Key(.h, modifiers): fallthrough
    case Key(.leftArrow, modifiers):
        currentScreen().previous()
    case Key(.l, modifiers): fallthrough
    case Key(.rightArrow, modifiers):
        currentScreen().next()

    case Key(.equals, modifiers):
        toggleFullScreen()

        default: print(key)
    }
}
