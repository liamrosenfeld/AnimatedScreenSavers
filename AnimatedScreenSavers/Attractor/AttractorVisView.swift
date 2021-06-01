//
//  AttractorVisView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/28/21.
//

import Foundation
import MetalKit
import simd.vector

class AttractorVisView: MTKView {
    // MARK: - Properties
    private var angle: Float = 0
    
    private let calculator: AttractorCalculator

    private let commandQueue: MTLCommandQueue
    private let rendererPipelineState: MTLRenderPipelineState
    
    // MARK: - Init
    required init(calc: AttractorCalculator, frame: CGRect) {
        self.calculator = calc
        
        // set metal thin
        let device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        
        // make library
        // bundle workaround is for screen saver
        let library = try! device.makeDefaultLibrary(bundle: Bundle(for: Self.self))
        
        // add shaders to pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        // configure pipeline
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.sampleCount = 1
        
        // make pipeline state from descriptor
        rendererPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // set frame and device
        super.init(
            frame: frame,
            device: device
        )
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        // add next however many points
        calculator.calcNextPoints()
        
        // get buffers
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let angleBuffer = device!.makeBuffer(
            bytes: &angle,
            length: MemoryLayout.size(ofValue: angle),
            options: []
        )
        
        let scaleBuffer = device!.makeBuffer(
            bytes: &calculator.scale,
            length: MemoryLayout.size(ofValue: calculator.scale),
            options: []
        )
        
        let pointBuffer = device!.makeBuffer(
            bytesNoCopy: calculator.pointBufferPtr.baseAddress!,
            length: calculator.bufferSize,
            options: [],
            deallocator: nil
        )
        
        // create encoder
        let renderPassDescriptor = self.currentRenderPassDescriptor!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(rendererPipelineState)
        
        // add buffers
        renderEncoder.setVertexBuffer(pointBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(angleBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(scaleBuffer, offset: 0, index: 2)
        
        // set path
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: calculator.pointIndex)
        
        // render
        renderEncoder.endEncoding()
        commandBuffer.present(currentDrawable!)
        commandBuffer.commit()

        // iterate to next angle
        angle += 0.005
    }
    
    override func viewDidMoveToWindow() {
        calculator.reset()
    }
}
