//
//  ParticleView.swift
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

import SwiftUI
import MetalKit

struct ParticleView: View {
    var body: some View {
        ParticleSystem(numParticle: UInt(5e4))
    }
}

struct ParticleView_Previews: PreviewProvider {
    static var previews: some View {
        ParticleView()
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct ParticleSystem: ViewRepresentable {
    
    let numParticle: UInt
    
    #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        return context.coordinator.view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        updateView(context)
    }
    
    #elseif os(iOS)
    func makeUIView(context: Context) -> some UIView {
        return context.coordinator.view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        updateView(context)
    }
    
    #endif
    
    func updateView(_ context: Context) {
        
    }
    
    func makeCoordinator() -> ParticleRenderer {
        return ParticleRenderer(numParticle)
    }
}
