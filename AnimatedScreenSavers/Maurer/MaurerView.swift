//
//  MaurerView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/18/22.
//

import AppKit

typealias MaurerConfig = (n: Int, d: Int)

class MaurerView: NSView {
    let maurerLayer = MaurerLayer()
    
    let roses: [MaurerConfig] = [
        (n: 2, d: 19),
        (n: 2, d: 31),
        (n: 2, d: 39),
        (n: 2, d: 41),
        (n: 2, d: 47),
        (n: 3, d: 47),
        (n: 3, d: 67),
        (n: 4, d: 31),
        (n: 4, d: 61),
        (n: 5, d: 31),
        (n: 5, d: 97),
        (n: 6, d: 31),
        (n: 6, d: 71),
        (n: 7, d: 19),
        (n: 8, d: 19),
        (n: 8, d: 19),
        (n: 22, d: 31),
        (n: 26, d: 37),
        (n: 36, d: 47),
        (n: 40, d: 37),
        (n: 44, d: 31),
        (n: 44, d: 34),
    ]
    
    var runloop: Task<Never, Never>?
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        // center the view
        maurerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        maurerLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // add layer
        self.layer?.addSublayer(maurerLayer)
        self.layer?.backgroundColor = .black
        
        // run
        runloop = Task {
            while true {
                await self.maurerLayer.play(roses.randomElement()!)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
