//
//  Terrain.swift
//  Mesh2
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import SceneKit
import GameplayKit

class Terrain {
    init(width: Int, depth: Int, squareSize: Int) {
        // sizing
        self.width = width
        self.depth = depth
        self.squareSize = squareSize
        self.cols = width / squareSize
        self.rows = depth / squareSize
        
        // noise
        let noise = GKNoise(GKPerlinNoiseSource())
        self.noiseMap = GKNoiseMap(
            noise,
            size: SIMD2(Double(rows) / 20, Double(cols) / 5),
            origin: SIMD2(0, 0),
            sampleCount: SIMD2(Int32(rows), Int32(cols) * 4),
            seamless: true
        )
        
        // node
        self.node = SCNNode()
        self.node.name = "terrain"
    }
    
    // sizing
    let width: Int
    let depth: Int
    let squareSize: Int
    let rows: Int
    let cols: Int
    
    // noise
    let noiseMap: GKNoiseMap
    var offset = 0
    
    // node
    let node: SCNNode
    
    func populateNode() {
        (0..<rows-1).forEach { y in
            let vertices: [SCNVector3] = (0..<cols).flatMap { x -> [SCNVector3] in
                let currentWidth  = CGFloat(x * squareSize)
                let currentHeight = noiseMap.valueAt(x, (offset + y) % rows)
                let nextHeight    = noiseMap.valueAt(x, (offset + y + 1) % rows)
                let currentDepth  = CGFloat(y * squareSize)
                let nextDepth     = currentDepth + CGFloat(squareSize)
                
                return [
                    SCNVector3(currentWidth, currentHeight, currentDepth),
                    SCNVector3(currentWidth, nextHeight, nextDepth)
                ]
            }
            
            let source = SCNGeometrySource(vertices: vertices)
            let indices = Array(0..<UInt8(source.vectorCount))
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangleStrip)
            
            let geometry = SCNGeometry(sources: [source], elements: [element])
            let geoNode = SCNNode(geometry: geometry)
            self.node.addChildNode(geoNode)
        }
    }
    
    func move() {
        offset += 1
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        populateNode()
    }
}

extension GKNoiseMap {
    @inline(__always) func valueAt(_ x: Int, _ y: Int) -> CGFloat {
        CGFloat(value(at: SIMD2(Int32(x), Int32(y))) * 100)
    }
}
