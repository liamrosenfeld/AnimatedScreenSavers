//
//  MaurerLayer.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/18/22.
//

import AppKit

class MaurerLayer: CALayer {
    @MainActor var path: CGMutablePath
    @MainActor var line: CAShapeLayer
    @MainActor var text: CATextLayer
    
    override init() {
        path = CGMutablePath()
        line = CAShapeLayer()
        text = CATextLayer()
        
        super.init()
        
        // configure line
        line.lineWidth = 1
        line.fillColor = .clear
        line.strokeColor = .white
        
        // configure text
        text.foregroundColor = .white
        text.fontSize = 15
        text.contentsScale = NSScreen.main?.backingScaleFactor ?? 1 // crisp text on retina
        text.anchorPoint = .zero
        
        // add sublayers
        self.addSublayer(line)
        self.addSublayer(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play(_ config: MaurerConfig) async {
        // setup
        await setup(config)
        let size = Double(min(frame.origin.x, frame.origin.y, 1000)) * 0.8
        
        // draw
        for theta in 0...360 {
            // find the minimum time until the next frame
            let nextFrame = ContinuousClock().now + .milliseconds(22)
            
            let nextPoint = calcPoint(theta: theta, n: config.n, d: config.d, size: size)
            await MainActor.run {
                path.addLine(to: nextPoint)
                line.path = path
            }
            
            try? await Task.sleep(until: nextFrame, clock: .continuous)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // reset
        await MainActor.run {
            path = CGMutablePath()
            line.path = path
        }
    }
    
    func calcPoint(theta: Int, n: Int, d: Int, size: Double) -> CGPoint {
        // multiply input theta by d to get the angle for the next point
        // also convert to radians
        let k = Double(theta * d) * (.pi / 180.0)
        
        // find radius to point on the rose curve
        let r = size * sin(Double(n) * k)
        
        // polar -> cartesian
        return CGPoint(x: r * cos(k), y: r * sin(k))
    }
    
    @MainActor
    func setup(_ config: MaurerConfig) {
        // disable all animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // setup text
        text.string = NSString(utf8String: "n: \(config.n), d: \(config.d)")
        text.frame = CGRect(
            origin: CGPoint(x: -frame.origin.x + 10, y: -frame.origin.y + 10),
            size: text.preferredFrameSize()
        )
        
        // move path to origin
        path.move(to: .zero)
        
        CATransaction.commit()
    }
}

