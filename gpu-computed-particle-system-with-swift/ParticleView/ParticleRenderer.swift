//
//  ParticleRenderer.swift
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

import Foundation
import MetalKit

class ParticleRenderer: NSObject {
    
    let view: MTKView = MTKView()
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let clearPass: MTLComputePipelineState
    let drawDotPass: MTLComputePipelineState
    let particleBuffer: MTLBuffer
    let numParticles: UInt
    
    init(_ numParticle: UInt) {
        
        let particles = ParticleRenderer.createRandomParticles(numParticle)
        
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue(),
            let particleBuffer = device.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particles.count, options: .storageModeShared),
            let library = device.makeDefaultLibrary(),
            let clearPass = ParticleRenderer.makeClearPassFcn(device, library),
            let drawPass = ParticleRenderer.makeDrawPassFcn(device, library) else { fatalError("Particle Renderer initialization failed.") }
        
        self.device = device
        self.commandQueue = commandQueue
        self.particleBuffer = particleBuffer
        self.clearPass = clearPass
        self.drawDotPass = drawPass
        self.numParticles = numParticle
        super.init()

        self.view.device = device
        self.view.framebufferOnly = false
        self.view.delegate = self
    }
    
    
    class func makeDrawPassFcn(_ device: MTLDevice, _ library: MTLLibrary) -> MTLComputePipelineState? {
        guard let drawPassFcn = library.makeFunction(name: "drawPassFcn") else {
            fatalError("Library could not find the function 'drawPassFcn'.")
        }
        
        do {
            return try device.makeComputePipelineState(function: drawPassFcn)
        } catch {
            return nil
        }
    }
    
    class func makeClearPassFcn(_ device: MTLDevice, _ library: MTLLibrary) -> MTLComputePipelineState? {
        guard let clearPassFcn = library.makeFunction(name: "clearPassFcn") else {
            fatalError("Library could not find the function 'clearPassFcn'.")
        }
        
        do {
            return try device.makeComputePipelineState(function: clearPassFcn)
        } catch {
            return nil
        }
    }
    
    class func createRandomParticles(_ numParticle: UInt) -> [Particle] {
        var particles: [Particle] = []
        
        for _ in 0...numParticle {
            let particle = Particle(color: simd_float4(1, 1, 1, 1),
                                    position: simd_float2(Float.random(in: 0...1), Float.random(in: 0...1)),  /// normalized screen pos [0...1, 0...1]
                                    velocity: simd_float2(Float.random(in: -1...1), Float.random(in: -1...1)))  /// velocity in [px / draw]
            particles.append(particle)
        }
        return particles
    }
}

extension ParticleRenderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard
            let drawable = view.currentDrawable,
            let commandBuffer = self.commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        
        
        // Encode clear pass
        commandEncoder.setComputePipelineState(self.clearPass)
        commandEncoder.setTexture(drawable.texture, index: 0)
        let w = self.clearPass.threadExecutionWidth  /// thread width of a group (number of columns aka px)
        let h = self.clearPass.maxTotalThreadsPerThreadgroup / w  /// thread height of a group (number of rows aka px) limited by max possible amount of threads per group
        var threadsPerGroup = MTLSize(width: w, height: h, depth: 1)
        var gridSize = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1) /// grid is composed of threadgroups and covers the whole texture
        commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerGroup)
        
        
        
        // Encode draw pass
        commandEncoder.setComputePipelineState(self.drawDotPass)
        commandEncoder.setBuffer(self.particleBuffer, offset: 0, index: 0)
        threadsPerGroup = MTLSize(width: w, height: 1, depth: 1)
        gridSize = MTLSizeMake(Int(self.numParticles), 1, 1)
        commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    

    
}
