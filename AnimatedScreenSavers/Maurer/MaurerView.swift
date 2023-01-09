//
//  MaurerView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/18/22.
//

import AppKit

struct MaurerConfig {
    var n: Int
    var d: Int
    
    /// find a random rose that looks decent
    static func random() -> MaurerConfig {
        while true {
            let n = Int.random(in: 2...35)
            let d = goodJumpAmounts.randomElement()!
            
            // my arbitrary conditions for pretty looking roses
            let a = (max(n, d) % min(n, d)) == 1
            let b = abs(n - d) > 10

            // trim the rose bush
            if a && b {
                return MaurerConfig(n: n, d: d)
            }
        }
    }
    
    private static let goodJumpAmounts = (15...70).filter { d in
        // check that it moves by a notable amount
        let offsetPerCycle = Int(ceil(360 / Float(d))) * d - 360
        if offsetPerCycle < 10 {
            return false
        }
        
        // check that it does not loop back to 0
        for i in 1..<360 {
            if (i * d) % 360 == 0 {
                return false
            }
        }
        
        return true
    }
}

class MaurerView: NSView {
    let maurerLayer = MaurerLayer()
    
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
                await self.maurerLayer.play(MaurerConfig.random())
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
