//
//  Shaders.metal
//  MetalExperiments
//
//  Created by Alexander Zimin on 15/10/2022.
//

#include <metal_stdlib>
using namespace metal;

struct Progress {
    float progress [[]];
};

struct Vertex {
    vector_float2 position [[]];
};

struct VertexInfos {
    float width;
    float height;
    uint32_t offset;
};

struct FragmentColors {
    vector_float4 color;
};

vertex vector_float4 draw_vertex(
  const device VertexInfos &infos [[buffer(0)]],
  const device Vertex *vertices [[buffer(1)]],
  const device Vertex *vertices2 [[buffer(2)]],
  const device Progress *progreses [[buffer(3)]],
  uint vertexId [[vertex_id]],
  uint instanceId [[instance_id]]
) {
    Vertex out = vertices[vertexId];
    
    if (vertexId > infos.offset) {
        uint index = vertexId - infos.offset;
        float progress = float(index) / float(1650);
        Vertex out2 = vertices2[index];
        out.position.x = out.position.x + (out2.position.x - out.position.x) * progress;
        out.position.y = out.position.y + (out2.position.y - out.position.y) * progress;
        
        out.position.x = 2 * (out.position.x / infos.width - 0.5) * 1;
        out.position.y = -2 * (out.position.y / infos.height - 0.5) * 1;
        
        vector_float4 result = vector_float4(out.position.x, out.position.y, 0, 1);

        return result;
    } else {
        out.position.x = 2 * (out.position.x / infos.width - 0.5) * 1;
        out.position.y = -2 * (out.position.y / infos.height - 0.5) * 1;
        vector_float4 result = vector_float4(out.position.x, out.position.y, 0, 1);

        return result;
    }
}

fragment float4 draw_fragment(
  Vertex interpolatedVertex [[stage_in]],
  constant FragmentColors &uniforms [[buffer(0)]]
) {
    return float4(uniforms.color.x, uniforms.color.y, uniforms.color.z, 1);
}
