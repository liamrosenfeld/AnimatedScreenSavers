//
//  HilbertShader.metal
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 10/25/22.
//

#include <metal_stdlib>
using namespace metal;

/// the center of each quadrant in counter clockwise order starting from top left
constant float2 quadCenters[] {
    float2(-0.5, 0.5),
    float2(-0.5, -0.5),
    float2(0.5, -0.5),
    float2(0.5, 0.5)
};

/// transforms for all curves within a quadrant
constant float2x2 transforms[] = {
    // 0 -> rotate by 90 deg counterclockwise then flip over y
    float2x2(0, -1,
             -1, 0),
    // 1, 2 -> no rotation
    float2x2(1, 0,
             0, 1),
    float2x2(1, 0,
             0, 1),
    // 3 -> rotate by 90 deg clockwise then flip over y
    float2x2(0, 1,
             1, 0),
};

float2 hilbert(uint idx, const uint order) {
    // start at origin and with identity transform
    float2 pos = float2(0, 0);
    float2x2 rot = float2x2(1, 0,
                            0, 1);
    
    // apply
    for (uint i = 0; i < order; i += 1) {
        // the quadrants of each step (from smallest to largest) are the last two bits.
        // get them in order of largest to smallest because we need to stack transformations
        uint quad = extract_bits(idx, (order - i - 1) * 2, 2);
        
        // find the next offset
        float2 offset = rot * quadCenters[quad];
        
        // shift the position by the scaled down offset
        // scale is 1 / 2^i because we are dividing into quarters each iteration
        pos += offset / float(1 << i);
        
        // apply the quadrant transformations for future iterations
        rot = rot * transforms[quad];
    }
    
    return pos;
}

struct Vertex {
    float4 pos [[position]];;
    float percent;
};

vertex Vertex hilbertVertexShader(
    constant uint& order [[ buffer(0) ]],
    uint id [[vertex_id]]
) {
    float2 pos = hilbert(id, order);
    
    float percentDone = float(id) / pow(float(1 << order), 2);
    
    return {
        float4(pos.x, pos.y, 0.0, 1.0),
        percentDone
    };
}

// super dense function off of stack overflow
float3 hsvToRgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

fragment float4 hilbertFragmentShader(Vertex in [[stage_in]]) {
    float3 rgb = hsvToRgb(float3(in.percent, 1, 1));
    return float4(rgb.x, rgb.y, rgb.z, 1.0);
}
