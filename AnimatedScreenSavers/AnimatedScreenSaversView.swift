//
//  AnimatedScreenSaversView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import ScreenSaver

class AnimatedScreenSaversView: ScreenSaverView {
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        let normalizedFrame = NSRect(origin: .zero, size: frame.size)
            
        let animation: Animation = .fourier
        let view: NSView = {
            switch animation {
            case .fourier:
                return FourierSceneView(frame: normalizedFrame)
            case .terrain:
                return TerrainSceneView(frame: normalizedFrame)
            }
        }()
        self.addSubview(view)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Animation {
    case fourier
    case terrain
}
