//
//  AppDelegate.swift
//  TesterApp
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let frame = NSRect(x: 0, y: 0, width: 1080, height: 720)

        // create window
        let win = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.setFrameAutosaveName("Main Window")

        // position window
        win.center()

        // add view to window
        let animation: Animation = .hilbert
        let view: NSView = {
            switch animation {
            case .fourier:
                return FourierView(frame: frame)
            case .attractor:
                return NSHostingView(rootView: AttractorView())
            case .hilbert:
                return SquareHilbertView(frame: frame)
            }
        }()
        win.contentView = view

        // open window
        // controllers are needed here to keep the app from crashing when a window is closed
        // if they are not used the app delegate get deallocated
        let controller = NSWindowController(window: win)
        controller.showWindow(self)
    }
}
