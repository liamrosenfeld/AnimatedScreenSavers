//
//  AttractorCalculator.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/29/21.
//

import simd

class AttractorCalculator {
    private var attractor: Attractor
    var scale: Float
    
    let pointBufferPtr: UnsafeMutableBufferPointer<SIMD3<Float>>
    let bufferSize: Int
    
    private let pointCount: Int
    private(set) var pointIndex: Int
    private var shouldReset: Bool
    private let pointsPerFrame: Int
    
    init() {
        // point count
        pointsPerFrame = 8
        pointCount = 4096 * (pointsPerFrame / 2) // has to be a multiple of 4096 and pointsPerFrame
        
        // create buffer
        pointBufferPtr = .allocate(capacity: pointCount)
        bufferSize = pointCount * MemoryLayout.size(ofValue: SIMD3<Float>())
        
        // attractor
        attractor = .lorenz
        scale = 0.05
        
        // set initial position
        pointIndex = 1
        shouldReset = false
        
        // setup
        reset()
    }
    
    private func reset() {
        attractor = .random()
        scale = attractor.scale()
        pointBufferPtr[0] = SIMD3<Float>(.random(in: 1..<2), .random(in: 1..<2), .random(in: 1..<2))
        pointIndex = 1
        shouldReset = false
    }
    
    func calcNextPoints() {
        if shouldReset {
            reset()
        }
        
        if pointIndex + pointsPerFrame < pointCount - 1 {
            for _ in 0...pointsPerFrame {
                calcPoint(at: pointIndex)
                pointIndex += 1
            }
        } else {
            reset()
        }
    }
    
    private func calcPoint(at index: Int) {
        let divisor: Float = 300.0
        let prevPt = pointBufferPtr[index - 1]
        let delta: SIMD3<Float> = {
            switch attractor {
            case .lorenz:
                let sigma: Float = 10.0
                let beta: Float = 2.5
                let rho: Float = 25.0
                return .init(
                    sigma * (prevPt.y - prevPt.x),
                    prevPt.x * (rho - prevPt.z) - prevPt.y,
                    prevPt.x * prevPt.y - beta * prevPt.z
                )
            case .chenLee:
                let alpha: Float = 5
                let beta: Float  = -10.0
                let sigma: Float = -0.38
                return .init(
                    alpha * prevPt.x -  prevPt.y * prevPt.z,
                    beta * prevPt.y + prevPt.x * prevPt.z,
                    sigma * prevPt.z + prevPt.x * (prevPt.y / 3.0)
                )
            case .halvorsen:
                let a: Float = 1.4
                return .init(
                    -a * prevPt.x - 4 * prevPt.y - 4 * prevPt.z - prevPt.y * prevPt.y,
                    -a * prevPt.y - 4 * prevPt.z - 4 * prevPt.x - prevPt.z * prevPt.z,
                    -a * prevPt.z - 4 * prevPt.x - 4 * prevPt.y - prevPt.x * prevPt.x
                )
            
            case .hadley:
                let alpha: Float = 0.2
                let beta: Float = 4.0
                let zeta: Float = 8
                let sigma: Float = 1.0
                return .init(
                    -prevPt.y * prevPt.y - prevPt.z * prevPt.z - alpha * prevPt.x + alpha * zeta,
                    prevPt.x * prevPt.y - beta * prevPt.x * prevPt.z - prevPt.y * sigma,
                    beta * prevPt.x * prevPt.y + prevPt.x * prevPt.z - prevPt.z
                )
            case .rossler:
                let a: Float = 0.2
                let b: Float = 0.3
                let c: Float = 8
                return .init(
                    -(prevPt.y + prevPt.z),
                    prevPt.x + a * prevPt.y,
                    b + prevPt.z * (prevPt.x - c)
                )
            case .lorenzModTwo:
                let a: Float = 0.9
                let b: Float = 5
                let c: Float = 9.9
                let d: Float = 1
                return .init(
                    -a * prevPt.x + prevPt.y * prevPt.y - prevPt.z * prevPt.z + a * c,
                    prevPt.x * (prevPt.y - b * prevPt.z) + d,
                    -prevPt.z + prevPt.x * (b * prevPt.y + prevPt.z)
                )
            }
        }()
        pointBufferPtr[index] = prevPt + (delta / divisor)
        
    }
}

enum Attractor: UInt {
    case lorenz
    case chenLee
    case halvorsen
    case hadley
    case rossler
    case lorenzModTwo
    
    func scale() -> Float {
        switch self {
        case .lorenz:
            return 0.022
        case .chenLee:
            return 0.023
        case .halvorsen:
            return 0.05
        case .hadley:
            return 0.3
        case .rossler:
            return 0.04
        case .lorenzModTwo:
            return 0.05
        }
    }
    
    static func random() -> Self {
        // Update as new enumerations are added
        let maxValue = lorenzModTwo.rawValue
        
        let rand = UInt.random(in: 0...maxValue)
        return Self(rawValue: rand)!
    }
}
