//
//  ContentView.swift
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ParticleView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
