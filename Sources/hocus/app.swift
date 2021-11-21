import Cocoa

func listenInput() {
    NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
        print("key \(event.keyCode)")
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("hocus")
        listenInput()
    }
}
