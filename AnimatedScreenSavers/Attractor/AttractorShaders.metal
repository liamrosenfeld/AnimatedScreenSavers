//
//  AttractorShaders.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/28/21.
//


#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];;
    float4 color;
};

vertex Vertex vertexShader(
    const device float3 *inPoints [[ buffer(0) ]],
    constant float &angle [[ buffer(1) ]],
    constant float &scale [[ buffer(2) ]],
    uint id [[vertex_id]]
) {
    Vertex out;

    float3 thisPoint = inPoints[id];

    float x = ((thisPoint.x * sin(angle)) + (thisPoint.z * cos(angle))) * scale;
    float y = thisPoint.y * scale;
    out.position = float4(x, y, 0.0, 1.0);
    
    float percentDone = float(id) / 16384;
    out.color = float4(percentDone, 1.0, 1.0 - percentDone, 1.0);
    
    return out;
}

fragment float4 fragmentShader(Vertex in [[stage_in]]) {
    return in.color;
}
