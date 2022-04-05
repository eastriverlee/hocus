//
//  modifier.swift
//  hocus
//
//  Created by eastriver lee on 2022/04/04.
//

import Cocoa

typealias Modifier = NSEvent.ModifierFlags
extension Modifier {
    init(_ keys: Set<Keycode>) {
       let rawValue = keys.reduce(0){ $0 | $1.rawValue }
       self = Modifier(rawValue: UInt(rawValue))
    }
    func contains(modifier: Modifier) -> Bool {
        self.rawValue | modifier.rawValue != 0
    }
}
