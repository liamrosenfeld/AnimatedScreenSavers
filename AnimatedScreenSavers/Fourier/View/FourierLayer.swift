//
//  FourierLayer.swift
//  Fourier Artist
//
//  Created by Liam on 2/10/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import AppKit

class FourierLayer: CALayer {
    /// the drawings have a maximum size of 1000x1000 plus some padding
    static let size: CGSize = CGSize(width: 1200, height: 1200)
    
    /// the angle traveled through an epicycle with a frequency of 1
    /// range for the drawing is [0, 2pi]
    private var theta = 0.0
    
    /// change in theta each frame
    private var delta = 0.0
    
    /// only use the largest (percent) number of epicycles
    private let percentAccuracy: Double = 0.45
    
    /// all circles to draw
    private var epicycles = [Wave]()
    
    /// the portion of the path that has been drawn so far
    private var path = [CGPoint]()
    
    /// the path through the circles (reset each frame)
    private var circlePath = [CGPoint]()
    
    private var circleLayer = CALayer()
    private var circleLineLayer = CALayer()
    private var drawnPathLayer = CALayer()
    
    // MARK: - Public
    override init() {
        super.init()
        
        // add the sublayers
        self.addSublayer(self.circleLayer)
        self.addSublayer(self.circleLineLayer)
        self.addSublayer(self.drawnPathLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play(_ epicycles: [Wave]) async {
        await newPath(epicycles)
        
        await growArm()
        
        while theta <= 2 * .pi {
            // find the minimum time until the next frame (at 40 fps)
            let nextFrame = ContinuousClock().now + .milliseconds(25)
            
            await next()
            
            try? await Task.sleep(until: nextFrame, clock: .continuous)
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await fadeArm()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Internal
    @MainActor
    private func newPath(_ epicycles: [Wave]) {
        // save epicycles (dropped)
        self.epicycles = epicycles.dropLast(Int(Double(epicycles.count) * (1.0 - percentAccuracy)))
        
        // it's important to have both lengths because the delta must be set on the original
        // so we will have that many points on the drawn path, but the number of points in the circle
        // path will be the lenght of the dropped version
        let origLen = epicycles.count
        let dropLen = self.epicycles.count
        
        // clear display
        CATransaction.begin()
        self.sublayers?.forEach { $0.sublayers = nil }
        CATransaction.commit()
        
        // prepare path for next
        path.removeAll(keepingCapacity: true)
        path.reserveCapacity(origLen)
        circlePath = [CGPoint](repeating: .zero, count: dropLen + 1)
        
        // set local variables
        theta = 0
        delta = Double.pi * 2 / Double(origLen)
    }
    
    private func growArm() async {
        var center = CGPoint(
            x: 600,
            y: 600
        )
        
        // Draw epicycles
        circlePath[0] = center
        for (idx, epi) in epicycles.enumerated() {
            let oldCenter = center
            
            // move center to next circle
            let phi = Double(epi.freq) * theta + epi.phase
            center.x += CGFloat(epi.amp * cos(phi))
            center.y += CGFloat(epi.amp * sin(phi))
            
            // Draw line to next center
            circlePath[idx + 1] = center
            
            // draw current circle and line up to this points
            await MainActor.run {
                CATransaction.begin()
                circleLayer.drawCircle(center: oldCenter, radius: epi.amp)
                circleLineLayer.sublayers = nil
                circleLineLayer.drawLine(through: circlePath[0...idx])
                CATransaction.commit()
            }
            
            // pause slower at the start and quicker at the end
            let initalPause: Double = 250_000_000
            let percentDone = Double(idx) / Double(self.epicycles.count)
            let timeScale = pow(2.0, -12 * percentDone)
            let pause = UInt64(initalPause * timeScale)
            if pause > 100_000 {
                try? await Task.sleep(nanoseconds: pause)
            }
        }
    }
    
    private func fadeArm() async {
        // fade out the circles
        await CATransaction.animateChange(over: 2) {
            self.circleLayer.opacity = 0
            self.circleLineLayer.opacity = 0
        }
        
        // remove them and set the opacity back to normal afterwards
        circleLayer.sublayers = nil
        circleLineLayer.sublayers = nil
        circleLayer.opacity = 1
        circleLineLayer.opacity = 1
    }
    
    @MainActor
    private func next() {
        // Disable all animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Clear screen
        self.sublayers?.forEach { $0.sublayers = nil }
        
        // Draw epicycles (and get next point to draw on path)
        let pointOnPath = drawEpicycles(epicycles)
        
        // Add new point to path
        path.insert(pointOnPath, at: 0)
        drawnPathLayer.drawLine(through: path)
        CATransaction.commit()
        
        // Increment theta
        theta += delta
    }
    
    private func drawEpicycles(_ epicycles: [Wave]) -> CGPoint {
        // Get starting point
        var center = CGPoint(
            x: 600,
            y: 600
        )
        
        // Draw epicycles
        circlePath[0] = center
        for (idx, epi) in epicycles.enumerated() {
            // draw current circle
            circleLayer.drawCircle(center: center, radius: epi.amp)
            
            // move center to next circle
            
            // a. the next center will be on the current circle,
            //    so we first must find the angle within the circle to it
            let phi = Double(epi.freq) * theta + epi.phase
            
            // b. then it's just basic trig to get the point
            center.x += CGFloat(epi.amp * cos(phi))
            center.y += CGFloat(epi.amp * sin(phi))
            
            // Draw line to next center
            circlePath[idx + 1] = center
        }
        
        circleLineLayer.drawLine(through: circlePath)
        
        return center
    }
}

extension CATransaction {
    @MainActor
    static func animateChange(over seconds: Double, _ change: () -> ()) async {
        await withCheckedContinuation { continuation in
            CATransaction.begin()
            CATransaction.setAnimationDuration(2)
            CATransaction.setCompletionBlock {
                continuation.resume()
            }
            change()
            CATransaction.commit()
        }
    }
}
