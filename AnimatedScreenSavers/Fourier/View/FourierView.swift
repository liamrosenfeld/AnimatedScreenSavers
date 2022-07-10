//
//  FourierView.swift
//  Fourier Artist
//
//  Created by Liam on 2/10/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import AppKit

class FourierView: NSView {
    let queue = FourierQueue()
    let fourierLayer = FourierLayer()
    
    var runloop: Task<Never, Never>?
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        // scale down if needed
        fourierLayer.frame = CGRect(origin: .zero, size: FourierLayer.size)
        let minSize = min(frame.width, frame.height)
        let layerSize: CGFloat = 1200
        if minSize < layerSize {
            let scale = minSize / layerSize
            fourierLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        }
        
        // center the view
        fourierLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fourierLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // add layer
        self.layer?.addSublayer(fourierLayer)
        self.layer?.backgroundColor = .black
        
        // compute first points, do rest in the background
        queue.loadIn()
        
        // run
        runloop = Task {
            while true {
                await self.fourierLayer.play(self.queue.next())
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
