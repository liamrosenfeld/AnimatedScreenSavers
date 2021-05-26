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
        
        let view = TerrainSceneView(frame: NSRect(origin: .zero, size: frame.size))
        self.addSubview(view)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
