//
//  Wave.swift
//  Fourier Artist
//
//  Created by Liam on 3/16/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import Foundation

struct Wave {
    var freq: Int
    var amp: Double
    var phase: Double
    
    init() {
        self.freq = 0
        self.amp = 0
        self.phase = 0
    }
    
    init(freq: Int, amp: Double, phase: Double) {
        self.freq = freq
        self.amp = amp
        self.phase = phase
    }
}
