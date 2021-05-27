//
//  Complex.swift
//  Fourier Artist
//
//  Created by Liam on 3/16/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import Foundation

struct Complex {
    // Properties
    var re: Double
    var im: Double
    
    // Operators
    static func *(left: Complex, right: Complex) -> Complex {
        // (a+bi)(c+di) = ac + adi + bci - bd = (ac - bd) + i(ad + bc)
        var mult = Complex()
        mult.re = left.re * right.re - left.im * right.im;
        mult.im = left.re * right.im + left.im * right.re;
        return mult
    }
    
    static func +=(left: inout Complex, right: Complex) {
        left.re += right.re
        left.im += right.im
    }
    
    static func +(left: Complex, right: Complex) -> Complex {
        return Complex(re: left.re + right.re, im: left.im + right.im)
    }
    
    // Initializers
    init() {
        self.re = 0
        self.im = 0
    }
    
    init(re: Double, im: Double) {
        self.re = re
        self.im = im
    }
}

extension CGPoint {
    var complex: Complex {
        get {
            let complex = Complex(re: Double(self.x), im: Double(self.y))
            return complex
        }
    }
}
