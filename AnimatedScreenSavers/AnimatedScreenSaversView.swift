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
        
        let animation = Animation.allCases.randomElement()!
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
}

enum Animation: CaseIterable {
    case fourier
    case attractor
    case hilbert
    case maurer
    case perlin
}
