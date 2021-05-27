//
//  Fourier.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import Foundation

func dft(_ points: [CGPoint]) -> [Wave] {
    let numPoints = points.count
    
    var epicycles = (0..<numPoints).map { pointNum -> Wave in
        // take the sum
        var sum = (0..<numPoints).reduce(Complex()) { partialSum, n in
            let phi = (2 * Double.pi * Double(pointNum) * Double(n)) / Double(numPoints)
            let cPhi = Complex(re: cos(phi), im: -sin(phi))
            return partialSum + (points[n].complex * cPhi)
        }
        
        // scale down
        sum.re /= Double(numPoints)
        sum.im /= Double(numPoints)
        
        // find properties of the wave
        let amp = sqrt(sum.re * sum.re + sum.im * sum.im)
        let phase = atan2(sum.im, sum.re)
        
        // Saves it into the array
        return Wave(freq: pointNum, amp: amp, phase: phase)
    }
    
    // sort by amplitude to look better
    epicycles.sort{ $0.amp > $1.amp }
    
    return epicycles
}
