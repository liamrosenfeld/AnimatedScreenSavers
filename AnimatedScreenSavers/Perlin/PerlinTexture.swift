//
//  PerlinTexture.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/20/22.
//

import Foundation
import GameKit

class PerlinTexture {
    /// cols is width, rows is depth
    init(cols: Int, rows: Int) {
        // sizing
        self.cols = cols
        self.rows = rows
        self.totalRows = rows * 20
        
        // noise
        let source = GKPerlinNoiseSource()
        source.persistence = 0.3
        source.seed = .random(in: Int32.min...Int32.max)
        let noise = GKNoise(source)
        self.noiseMap = GKNoiseMap(
            noise,
            size: SIMD2(Double(cols) / 10, Double(totalRows) / 10),
            origin: SIMD2(0, 0),
            sampleCount: SIMD2(Int32(cols), Int32(totalRows)),
            seamless: true
        )
        
        // create vertex index
        vertexIndex = []
        var i: UInt16 = 0
        for _ in 0..<rows {
            for _ in (0..<cols) {
                vertexIndex.append(i)
                i += 1
                vertexIndex.append(i)
                i += 1
            }
            vertexIndex.append(0xFFFF)
        }
        
        // create empty vertices
        self.vertices = .init(repeating: .zero, count: rows * 2 * (cols))
    }
    
    // sizing
    private let rows: Int
    private let cols: Int
    private let totalRows: Int
    
    // noise
    private let noiseMap: GKNoiseMap
    private var offset = 0
    
    // metal vertices
    private(set) var vertices: [SIMD3<Float>]
    private(set) var vertexIndex: [UInt16]
    
    func populateVertices() {
        for row in 0..<rows {
            let rowStart = row * 2 * cols
            
            for col in (0..<cols) {
                let xLoc    = Float(col) * 2 / Float(cols - 1)
                let zLoc    = Float(row) * 2 / Float(rows - 1)
                let zLocNext = (Float(row) + 1) * 2 / Float(rows - 1)
                let val     = noiseMap.valueAt(col, (offset + row) % totalRows) + 1 // make [0, 2]
                let nextVal = noiseMap.valueAt(col, (offset + row + 1) % totalRows) + 1
                
                vertices[rowStart + (2 * col)]     = SIMD3(xLoc, val, zLoc)
                vertices[rowStart + (2 * col) + 1] = SIMD3(xLoc, nextVal, zLocNext)
            }
        }
    }
    
    func next() {
        offset = (offset + 1) % totalRows
    }
}

extension GKNoiseMap {
    @inline(__always) func valueAt(_ x: Int, _ y: Int) -> Float {
        value(at: SIMD2(Int32(x), Int32(y)))
    }
}
