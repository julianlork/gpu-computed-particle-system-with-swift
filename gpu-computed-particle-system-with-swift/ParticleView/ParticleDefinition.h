//
//  ParticleDefinition.h
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

#ifndef ParticleDefinition_h
#define ParticleDefinition_h

#include <simd/simd.h>

struct Particle {
    vector_float4 color;
    vector_float2 position;
    vector_float2 velocity;
};


#endif /* ParticleDefinition_h */
