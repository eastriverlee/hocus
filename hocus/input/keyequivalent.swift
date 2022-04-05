//
//  keyequivalent.swift
//  hocus
//
//  Created by eastriver lee on 2022/04/04.
//

import Foundation
enum KeyEquivalent: UInt32 {
    case upArrow = 0xF700
    case downArrow = 0xF701
    case leftArrow = 0xF702
    case rightArrow = 0xF703
    case f1  = 0xF704
    case f2  = 0xF705
    case f3  = 0xF706
    case f4  = 0xF707
    case f5  = 0xF708
    case f6  = 0xF709
    case f7  = 0xF70A
    case f8  = 0xF70B
    case f9  = 0xF70C
    case f10 = 0xF70D
    case f11 = 0xF70E
    case f12 = 0xF70F
    case f13 = 0xF710
    case f14 = 0xF711
    case f15 = 0xF712
    case f16 = 0xF713
    case f17 = 0xF714
    case f18 = 0xF715
    case f19 = 0xF716
    case f20 = 0xF717
    case f21 = 0xF718
    case f22 = 0xF719
    case f23 = 0xF71A
    case f24 = 0xF71B
    case f25 = 0xF71C
    case f26 = 0xF71D
    case f27 = 0xF71E
    case f28 = 0xF71F
    case f29 = 0xF720
    case f30 = 0xF721
    case f31 = 0xF722
    case f32 = 0xF723
    case f33 = 0xF724
    case f34 = 0xF725
    case f35 = 0xF726
    case insert = 0xF727
    case delete = 0xF728
    case home = 0xF729
    case begin = 0xF72A
    case end = 0xF72B
    case pageUp = 0xF72C
    case pageDown = 0xF72D
    case printScreen = 0xF72E
    case scrollLock = 0xF72F
    case pause = 0xF730
    case sysReq = 0xF731
    case _break = 0xF732
    case reset = 0xF733
    case stop = 0xF734
    case menu = 0xF735
    case user = 0xF736
    case system = 0xF737
    case print = 0xF738
    case clearLine = 0xF739
    case clearDisplay = 0xF73A
    case insertLine = 0xF73B
    case deleteLine = 0xF73C
    case insertChar = 0xF73D
    case deleteChar = 0xF73E
    case prev = 0xF73F
    case next = 0xF740
    case select = 0xF741
    case execute = 0xF742
    case undo = 0xF743
    case redo = 0xF744
    case find = 0xF745
    case help = 0xF746
    case modeSwitch = 0xF747
    
    var string: String { String(Character(UnicodeScalar(rawValue)!)) }
}
