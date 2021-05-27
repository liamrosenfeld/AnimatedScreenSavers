//
//  FourierScene.swift
//  Fourier Artist
//
//  Created by Liam on 2/10/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import SpriteKit
import Foundation
import Combine

class FourierScene: SKScene {
    // MARK: - Properties
    // time
    private var theta = 0.0
    private var delta = 0.0
    
    // what has been drawn so far
    private var path = [CGPoint]()
    
    // what to draw
    var epicycles = [Wave]() {
        didSet {
            path.removeAll()
            theta = 0
            self.removeAllChildren()
            delta = Double.pi * 2 / Double(epicycles.count)
        }
    }
    
    // interactions
    private(set) var finished = PassthroughSubject<Void, Never>()
    
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
    }
    
    // MARK: - Cycle
    override func update(_: TimeInterval) {
        // Reset
        self.removeAllChildren()
        
        // Draw Epicycles and Get Next Point For Shape
        let pointOnPath = drawEpicycles(epicycles)
        
        // Add New Point To Path and Connect It
        path.insert(pointOnPath, at: 0)
        drawLine(through: path)
        
        // Update Time (The Theta of the Circle)
        theta += delta
        if (theta > Double.pi * 2) {
            finished.send()
            theta = 0
            path.removeAll()
        }
    }
    
    func drawEpicycles(_ epicycles: [Wave]) -> CGPoint {
        // Get Starting Point
        var center = CGPoint(x: Double(self.frame.width / 2),
                             y: Double(self.frame.height / 2))
        
        // Draw Epicycles
        for epi in epicycles {
            let prevCenter = center
            
            // Properties of The Vector
            let freq = epi.freq
            let radius = epi.amp
            let phase = epi.phase
            
            // Find Next Center
            let phi = Double(freq) * theta + phase
            center.x += CGFloat(radius * cos(phi))
            center.y += CGFloat(radius * sin(phi))
            
            // Draw Ellipse and Line Connecting Centers
            drawCircle(center: prevCenter, radius: radius)
            drawLine(from: prevCenter, to: center)
        }
        
        return center
    }
}


