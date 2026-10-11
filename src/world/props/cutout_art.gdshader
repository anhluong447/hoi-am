shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D atlas : source_color, filter_nearest_mipmap;
uniform vec2 atlas_size;
uniform float texel_step = 1.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
    vec2 sampled = (floor(UV * atlas_size / texel_step) + 0.5) * texel_step / atlas_size;
    vec4 ink = texture(atlas, sampled) * tint;
    ALBEDO = ink.rgb;
    ALPHA = ink.a;
    ALPHA_SCISSOR_THRESHOLD = 0.65;
    ROUGHNESS = 1.0;
}
