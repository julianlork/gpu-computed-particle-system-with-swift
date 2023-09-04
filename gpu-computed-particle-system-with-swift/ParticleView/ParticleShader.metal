//
//  ParticleShader.metal
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

#include <metal_stdlib>
#include "ParticleDefinition.h"

using namespace metal;
constant half4 BACKGROUND_COL = half4(0.1, 0.1, 0.1, 1);

float2 getPixelPosition(float2 normalizedPos, float2 screenSizeInPx) {
    return float2(normalizedPos.x * screenSizeInPx.x, normalizedPos.y * screenSizeInPx.y);
}

float2 getNormalizedPosition(float2 pxPos, float2 screenSizeInPx) {
    return float2(pxPos.x / screenSizeInPx.x, pxPos.y / screenSizeInPx.y);
}


/// Shader that clears the texture by coloring each pixel accoridng to the background color
kernel void clearPassFcn(texture2d<half, access::write> texture [[texture(0)]], uint2 pxID [[thread_position_in_grid]]) {
    texture.write(BACKGROUND_COL, pxID);
}

kernel void drawPassFcn(texture2d<half, access::write> texture [[texture(0)]],
                        device Particle *particles [[buffer(0)]],
                        uint particleID [[thread_position_in_grid]]) {
    
    float pxWidth = texture.get_width();
    float pxHeight = texture.get_height();
    float2 screenSize = float2(pxWidth, pxHeight);
    
    float2 velocity = particles[particleID].velocity;
    float2 position = particles[particleID].position;
    float4 color = particles[particleID].color;
    
    float2 pxPosition = getPixelPosition(position, screenSize);
    
    if(pxPosition.x < 0 || pxPosition.x > pxWidth) velocity.x *= -1;
    if(pxPosition.y < 0 || pxPosition.y > pxHeight) velocity.y *= -1;
    
    pxPosition += velocity;
    
    uint2 texturePosition = uint2(pxPosition.x, pxPosition.y);
    half4 pxColor = half4(color.r, color.g, color.b, 1);
    texture.write(pxColor, texturePosition);
    texture.write(pxColor, texturePosition + uint2(1,0));
    texture.write(pxColor, texturePosition + uint2(0,1));
    texture.write(pxColor, texturePosition - uint2(1,0));
    texture.write(pxColor, texturePosition - uint2(0,1));
    
    /// Normalized space: update particle
    position = getNormalizedPosition(pxPosition, screenSize);
    particles[particleID].velocity = velocity;
    particles[particleID].position = position;
}



