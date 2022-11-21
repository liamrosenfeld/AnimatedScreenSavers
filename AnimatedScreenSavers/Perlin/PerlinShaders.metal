//
//  PerlinShaders.metal
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/19/22.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];;
    float4 color;
};

vertex Vertex perlinVertexShader(
    const device float3 *inPoints [[ buffer(0) ]],
    uint id [[vertex_id]]
) {
    float3 pt = inPoints[id];
    
    // rotate forward
    const float angle = M_PI_F / 3.5;
    const float3x3 rot = float3x3(1,      0,     0,
                                  0,  cos(angle), -sin(angle),
                                  0, sin(angle), cos(angle));
    float3 rotated = rot * pt;
    
    // scale & shift
    float4 shifted = float4(rotated.x - 1,
                            (rotated.y * 0.8) - 2,
                            (rotated.z * 0.3) + 0.3,
                            1.0);
    
    // shade
    float4 color = float4(abs(1.0 - (pt.z / 2)),
                          abs(1.0 - (pt.z / 3)),
                          abs(1.0 - (pt.y / 4)),
                          1.0);
    
    return {shifted, color};
}

fragment float4 perlinFragmentShader(Vertex in [[stage_in]]) {
    return in.color;
}
