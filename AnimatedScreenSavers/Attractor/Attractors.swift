//
//  Attractors.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/31/21.
//

enum Attractor {
    // MARK: - Cases + Default Values
    case lorenz(
            sigma: Float = 10,
            beta: Float = 2.5,
            rho: Float = 25
         )
    case chenLee(
            alpha: Float = 5,
            beta: Float = -10,
            delta: Float = -0.38
         )
    case halvorsen(
            a: Float = 1.4
         )
    case hadley(
            alpha: Float = 0.2,
            beta: Float = 4.0,
            zeta: Float = 8,
            delta: Float = 1.0
         )
    case rossler(
            a: Float = 0.2,
            b: Float = 0.3,
            c: Float = 8
         )
    case lorenzModTwo(
            alpha: Float = 0.9,
            beta: Float = 5,
            zeta: Float = 9.9,
            delta: Float = 1
         )
    
    // MARK: - Display Requirements
    var scale: Float {
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
            return 0.03
        case .lorenzModTwo:
            return 0.05
        }
    }
    
    func getAnInitialCondition() -> SIMD3<Float> {
        switch self {
        case .chenLee:
            return SIMD3<Float>(.random(in: -2...2), .random(in: -2...2), .random(in: 1.4...2))
        default:
            return SIMD3<Float>(.random(in: -2...2), .random(in: -2...2), .random(in: -2...2))
        }
    }
    
    // MARK: - Text Representation
    var name: String {
        switch self {
        case .lorenz:
            return "Lorenz"
        case .chenLee:
            return "Chen Lee"
        case .halvorsen:
            return "Halvorsen"
        case .hadley:
            return "Hadley"
        case .rossler:
            return "Rössler"
        case .lorenzModTwo:
            return "Lorenz Mod 2"
        }
    }
    
    var equations: String {
        switch self {
        case .lorenz:
            return """
                x' = σ(y - x)
                y' = x(ρ - z) - y
                z' = xy - βz
                """
        case .chenLee:
            return """
                x' = ɑx - yz
                y' = βy + xz
                z' = δz + x(y/3)
                """
        case .halvorsen:
            return """
                x' = -ax - 4y - 4z - y²
                y' = -ay - 4z - 4x - z²
                z' = -az - 4x - 4y - x²
                """
        case .hadley:
            return """
                x' = -y² - z² - ɑx + ɑζ
                y' = xy - βxz - y + δ
                z' = βxy + xz - z
                """
        case .rossler:
            return """
                x' = -y - z
                y' = x + ay
                z' = b + z(x - c)
                """
        case .lorenzModTwo:
            return """
                x' = -ax + y² - z² + aζ
                y' = x(y - βz) + δ
                z' = -z + x(βy + z)
                """
        }
    }
    
    var constants: String {
        switch self {
        case .lorenz(let sigma, let beta, let rho):
            return """
                σ = \(sigma)
                β = \(beta)
                ρ = \(rho)
                """
        case .chenLee(let alpha, let beta, let delta):
            return """
                ɑ = \(alpha)
                β = \(beta)
                δ = \(delta)
                """
        case .halvorsen(let a):
            return """
                a = \(a)
                """
        case .hadley(let alpha, let beta, let zeta, let delta):
            return """
                ɑ = \(alpha)
                β = \(beta)
                ζ = \(zeta)
                δ = \(delta)
                """
        case .rossler(let a, let b, let c):
            return """
                a = \(a)
                b = \(b)
                c = \(c)
                """
        case .lorenzModTwo(let alpha, let beta, let zeta, let delta):
            return """
                ɑ = \(alpha)
                β = \(beta)
                ζ = \(zeta)
                δ = \(delta)
                """
        }
    }
    
    // MARK: - Random
    static func random() -> Self {
        let rand = UInt.random(in: 0...5)
        switch rand {
        case 0:
            return .lorenz()
        case 1:
            return .chenLee()
        case 2:
            return .halvorsen()
        case 3:
            return .hadley()
        case 4:
            return .rossler()
        case 5:
            return .lorenzModTwo()
        default:
            preconditionFailure("Unimplemented ID")
        }
    }
}
