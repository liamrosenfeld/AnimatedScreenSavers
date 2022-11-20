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

vertex Vertex attractorVertexShader(
    const device float3 *inPoints [[ buffer(0) ]],
    constant float &angle [[ buffer(1) ]],
    constant float &scale [[ buffer(2) ]],
    uint id [[vertex_id]]
) {
    Vertex out;

    // rotate about y axis and scale down
    float3 pt = inPoints[id];
    float3x3 rot = float3x3(cos(angle), 0, sin(angle),
                                     0, 1,          0,
                           -sin(angle), 0, cos(angle));
    pt = rot * pt * scale;
    out.position = float4(pt.x, pt.y, pt.z / 4 + 0.5, 1.0);
    
    float percentDone = float(id) / 16384;
    out.color = float4(percentDone, 1.0, 1.0 - percentDone, 1.0);
    
    return out;
}

fragment float4 attractorFragmentShader(Vertex in [[stage_in]]) {
    return in.color;
}
