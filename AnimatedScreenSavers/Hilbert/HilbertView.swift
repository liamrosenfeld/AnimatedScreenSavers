//
//  HilbertView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 10/25/22.
//

import Foundation
import MetalKit
import simd.vector

class HilbertView: MTKView {
    // MARK: - Properties
    private let commandQueue: MTLCommandQueue
    private let rendererPipelineState: MTLRenderPipelineState
    
    var order = 1
    var points = 1
    
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
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "hilbertVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "hilbertFragmentShader")
        
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
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        // get buffers
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let orderBuffer = device!.makeBuffer(
            bytes: &order,
            length: MemoryLayout.size(ofValue: order),
            options: []
        )

        // create encoder
        let renderPassDescriptor = self.currentRenderPassDescriptor!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(rendererPipelineState)
        
        // add buffers
        renderEncoder.setVertexBuffer(orderBuffer, offset: 0, index: 0)
        
        // set path
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: points)
        
        // render
        renderEncoder.endEncoding()
        commandBuffer.present(currentDrawable!)
        commandBuffer.commit()
        
        // increment
        let maxPoints = (1 << order) * (1 << order)
        if points == maxPoints {
            points = 1
            if order == 7 {
                order = 1
            } else {
                order += 1
            }
        } else {
            points += 1
        }
    }
}


