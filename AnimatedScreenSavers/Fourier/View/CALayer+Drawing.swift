//
//  CALayer+Drawing.swift
//  Fourier Artist
//
//  Created by Liam on 6/5/22.
//  Copyright © 2022 Liam Rosenfeld. All rights reserved.
//

import AppKit

extension CALayer {
    func drawLine(through points: [CGPoint], color: CGColor? = nil) {
        // make path
        let path = CGMutablePath()
        path.move(to: points[0])
        path.addLines(between: points)
        
        // draw line
        let line = CAShapeLayer()
        line.path = path
        line.lineWidth = 1
        line.fillColor = .clear
        line.strokeColor = color ?? .white
        self.addSublayer(line)
    }
    
    func drawLine(through points: ArraySlice<CGPoint>, color: CGColor? = nil) {
        // make path
        let path = CGMutablePath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        // draw line
        let line = CAShapeLayer()
        line.path = path
        line.lineWidth = 1
        line.fillColor = .clear
        line.strokeColor = color ?? .white
        self.addSublayer(line)
    }
    
    func drawCircle(center: CGPoint, radius: Double) {
        // Find Square Inscribing Circle
        let corner = CGPoint(x: Double(center.x) - radius, y: Double(center.y) - radius)
        let frame = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(origin: corner, size: frame)
        
        // Draw Circle in Square
        let circle = CAShapeLayer()
        circle.path = CGPath(ellipseIn: rect, transform: nil)
        circle.strokeColor = .white.copy(alpha: 0.5)
        circle.fillColor = .clear
        self.addSublayer(circle)
    }
}
