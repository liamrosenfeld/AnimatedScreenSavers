//
//  AttractorCalculator.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/29/21.
//

import simd
import Combine

class AttractorCalculator {
    private var attractor: Attractor
    var scale: Float
    let newAttractor = PassthroughSubject<(Attractor, SIMD3<Float>), Never>()
    
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
        attractor = .lorenz()
        scale = 0.05
        
        // set initial position
        pointIndex = 1
        shouldReset = false
    }
    
    func reset() {
        attractor = .random()
        let initialCondition = attractor.getAnInitialCondition()
        newAttractor.send((attractor, initialCondition))
        scale = attractor.scale
        pointBufferPtr[0] = initialCondition
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
            case .lorenz(let sigma, let beta, let rho):
                return .init(
                    sigma * (prevPt.y - prevPt.x),
                    prevPt.x * (rho - prevPt.z) - prevPt.y,
                    prevPt.x * prevPt.y - beta * prevPt.z
                )
            case .chenLee(let alpha, let beta, let delta):
                return .init(
                    (alpha * prevPt.x) - (prevPt.y * prevPt.z),
                    (beta * prevPt.y) + (prevPt.x * prevPt.z),
                    (delta * prevPt.z) + (prevPt.x * (prevPt.y / 3.0))
                )
            case .halvorsen(let a):
                return .init(
                    -a * prevPt.x - 4 * prevPt.y - 4 * prevPt.z - prevPt.y * prevPt.y,
                    -a * prevPt.y - 4 * prevPt.z - 4 * prevPt.x - prevPt.z * prevPt.z,
                    -a * prevPt.z - 4 * prevPt.x - 4 * prevPt.y - prevPt.x * prevPt.x
                )
            case .hadley(let alpha, let beta, let zeta, let delta):
                return .init(
                    -prevPt.y * prevPt.y - prevPt.z * prevPt.z - alpha * prevPt.x + alpha * zeta,
                    prevPt.x * prevPt.y - beta * prevPt.x * prevPt.z - prevPt.y * delta,
                    beta * prevPt.x * prevPt.y + prevPt.x * prevPt.z - prevPt.z
                )
            case .rossler(let a, let b, let c):
                return .init(
                    -(prevPt.y + prevPt.z),
                    prevPt.x + a * prevPt.y,
                    b + prevPt.z * (prevPt.x - c)
                )
            case .lorenzModTwo(let alpha, let beta, let zeta, let delta):
                return .init(
                    -alpha * prevPt.x + prevPt.y * prevPt.y - prevPt.z * prevPt.z + alpha * zeta,
                    prevPt.x * (prevPt.y - beta * prevPt.z) + delta,
                    -prevPt.z + prevPt.x * (beta * prevPt.y + prevPt.z)
                )
            }
        }()
        pointBufferPtr[index] = prevPt + (delta / divisor)
        
    }
}
