shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D atlas : source_color, filter_nearest_mipmap;
uniform vec4 atlas_region;
uniform vec2 repeat_count = vec2(1.0);
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
    vec2 local = fract(UV * repeat_count);
    vec4 ink = texture(atlas, atlas_region.xy + local * atlas_region.zw);
    ALBEDO = ink.rgb * tint.rgb;
    ROUGHNESS = 1.0;
}
