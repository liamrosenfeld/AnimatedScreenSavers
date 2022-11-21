//
//  NewTerrain.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/19/22.
//

import Foundation
import MetalKit

class PerlinView: MTKView {
    // MARK: - Properties
    private let commandQueue: MTLCommandQueue
    private let rendererPipelineState: MTLRenderPipelineState
    
    let terrain = PerlinTexture(cols: 40, rows: 70)
    
    // MARK: - Init
    required init(frame: CGRect) {
        // set metal thin
        let device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        
        // make library
        // bundle workaround is for screen saver
        let library = try! device.makeDefaultLibrary(bundle: Bundle(for: Self.self))
        
        // add shaders to pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "perlinVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "perlinFragmentShader")
        
        // configure pipeline
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.rasterSampleCount = 4
        
        // make pipeline state from descriptor
        rendererPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // set frame and device
        super.init(
            frame: frame,
            device: device
        )
        
        self.sampleCount = 4
        self.preferredFramesPerSecond = 25
        
        // scale down for performance if needed
        let scale = 2000 / frame.width
        if scale < 1 {
            self.drawableSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        // get buffers
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        // create encoder
        let renderPassDescriptor = self.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(rendererPipelineState)
        
        // lines look cooler
        renderEncoder.setTriangleFillMode(.lines)
        
        // provide the vertices to the shader
        let vertexBuffer = device!.makeBuffer(
            bytes: terrain.vertices,
            length: terrain.vertices.count * MemoryLayout<SIMD3<Float>>.stride,
            options: []
        )!
        renderEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        
        // draw the triangle strips separately
        let indexBuffer = device!.makeBuffer(
            bytes: terrain.vertexIndex,
            length: terrain.vertexIndex.count * MemoryLayout<UInt16>.stride,
            options: []
        )!
        renderEncoder.drawIndexedPrimitives(
            type: .triangleStrip,
            indexCount: terrain.vertexIndex.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
        
        // render
        renderEncoder.endEncoding()
        commandBuffer.present(currentDrawable!)
        commandBuffer.commit()
        
        // increment
        terrain.next()
        terrain.populateVertices()
    }
}
