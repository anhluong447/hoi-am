shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 tint : source_color;
uniform float density;
uniform float grain;
uniform float seam;
uniform bool floor_surface;
varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = floor_surface ? world_position.xz : vec2(world_position.x + world_position.z, world_position.y);
    vec2 cell = p * density;
    float line = floor_surface ? step(0.96, fract(cell.y)) + step(0.995, fract(cell.x * 0.25 + floor(cell.y) * 0.5)) : 0.0;
    float texture_grain = sin(p.x * 43.0 + sin(p.y * 8.0)) * sin(p.y * 71.0);
    ALBEDO = tint.rgb * (1.0 + grain * texture_grain - min(line, 1.0) * seam);
    ROUGHNESS = 0.86;
}
