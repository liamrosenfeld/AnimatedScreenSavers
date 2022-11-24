//
//  AnimatedScreenSaversView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import ScreenSaver
import SwiftUI

class AnimatedScreenSaversView: ScreenSaverView {
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        let normalizedFrame = NSRect(origin: .zero, size: frame.size)
        
        let animation: Animation = {
            if frame.width < 100 {
                // override normal settings if preview (to look good small)
                return .perlin
            } else {
                // pick random enabled animation
                return SettingsStore.loadFromFile().animations.toSet().randomElement() ?? .attractor
            }
        }()
        
        let view: NSView = {
            switch animation {
            case .fourier:
                return FourierView(frame: normalizedFrame)
            case .attractor:
                let view = NSHostingView(rootView: AttractorView())
                view.frame = normalizedFrame
                return view
            case .hilbert:
                return SquareHilbertView(frame: normalizedFrame)
            case .maurer:
                return MaurerView(frame: normalizedFrame)
            case .perlin:
                return PerlinView(frame: normalizedFrame)
            }
        }()
        self.addSubview(view)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Settings
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 360),
            styleMask: [.titled, .fullSizeContentView, .utilityWindow],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Settings")
        let view = NSHostingView(rootView: SettingsView(window: window).padding())
        window.contentView = view
        return window
    }
}
