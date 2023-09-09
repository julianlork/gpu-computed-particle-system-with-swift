//
//  ParticleShader.metal
//  gpu-computed-particle-system-with-swift
//
//  Created by Julian Lork on 04.09.23.
//

#include <metal_stdlib>
#include "ParticleDefinition.h"

using namespace metal;
constant float COLOR_BOUNDARY = 0.33;

float2 getPixelPosition(float2 normalizedPos, float2 screenSizeInPx) {
    return normalizedPos * screenSizeInPx;
}

float2 getNormalizedPosition(float2 pxPos, float2 screenSizeInPx) {
    return pxPos / screenSizeInPx;
}

/// This function returns an increasingly red color array as soon as the px position falls below a certain distance to the lower or upper boundary
half4 getColorForPos(float2 normalizedPos) {
    float distToUprAndLwrBoundary = min(normalizedPos.y, 1.0 - normalizedPos.y);
    float modifier = distToUprAndLwrBoundary / COLOR_BOUNDARY;
    return half4(1.0, modifier, modifier, 1.0);
}

/// Shader that reduces each pixel for each draw to create a trail effect
kernel void clearPassFcn(texture2d<half, access::read_write> texture [[texture(0)]], uint2 pxID [[thread_position_in_grid]]) {
    
    half4 actPxColor = texture.read(pxID);
    actPxColor -= half4(1.0, 1.0, 1.0, 0.0) * 0.05;
    actPxColor = max(actPxColor, half4(0.0, 0.0, 0.0, 1.0));
    
    texture.write(actPxColor, pxID);
}

kernel void drawPassFcn(texture2d<half, access::write> texture [[texture(0)]],  ///, access::write
                        device Particle *particles [[buffer(0)]],
                        uint particleID [[thread_position_in_grid]]) {
    
    float pxWidth = texture.get_width();
    float pxHeight = texture.get_height();
    float2 screenSize = float2(pxWidth, pxHeight);
    
    float2 velocity = particles[particleID].velocity;
    float2 position = particles[particleID].position;
    
    /// convert to pixel space & update pixel space position
    float2 pxPosition = getPixelPosition(position, screenSize);
    pxPosition += velocity;
    
    if(pxPosition.x <= 0 || pxPosition.x > pxWidth) velocity.x *= -1;
    if(pxPosition.y <= 0 || pxPosition.y > pxHeight) velocity.y *= -1;
    

    /// convert to normalized space and update particle
    position = getNormalizedPosition(pxPosition, screenSize);
    particles[particleID].velocity = velocity;
    particles[particleID].position = position;
    
    /// draw updated position
    half4 pxColor = getColorForPos(position);
    uint2 texturePosition = uint2(pxPosition.x, pxPosition.y);
    texture.write(pxColor, texturePosition);
    texture.write(pxColor, texturePosition + uint2(1,0));
    texture.write(pxColor, texturePosition + uint2(0,1));
    texture.write(pxColor, texturePosition - uint2(1,0));
    texture.write(pxColor, texturePosition - uint2(0,1));
}



kernel void gausianPass(texture2d<half, access::read_write> texture [[texture(0)]], uint2 pxID [[thread_position_in_grid]]) {
    
    uint pxX = pxID.x;
    uint pxY = pxID.y;
    half4 pxResult = half4(0, 0, 0, 1);
    
    float gaussianblur[5][5] = {{1, 4, 6, 4, 1},
                                {4, 16, 24, 16, 4},
                                {6, 24, 36, 24, 6},
                                {4, 16, 24, 16, 4},
                                {1, 4, 6, 4, 1}};
    
    
    for(int x=-2; x <= 2; x++) {
        for(int y=-2; y <= 2; y++) {
            int despxX = pxX - x;
            int despxY = pxY - y;
            float modifer = gaussianblur[x+2][y+2];
            half4 pxValue;
            
            if(despxX < 0 || despxY < 0 || despxX > (int) texture.get_width() || despxY > (int) texture.get_height()){
                pxValue = texture.read(pxID);
            }else{
                pxValue = texture.read(ushort2(despxX, despxY));
            }
            
            pxResult.x += pxValue.x * modifer;
            pxResult.y += pxValue.y * modifer;
            pxResult.z += pxValue.z * modifer;
        }
    }
    
    
    texture.write(pxResult/half4(256, 256, 256, 1.0), pxID);
    
}

