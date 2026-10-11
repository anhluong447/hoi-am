shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D atlas : source_color, filter_nearest_mipmap;
uniform vec4 atlas_region;
uniform vec2 repeat_count = vec2(1.0);
uniform vec4 tint : source_color = vec4(1.0);
uniform float ink_strength = 1.0;
uniform bool swap_axes = false;

void fragment() {
    vec2 tiled = (swap_axes ? UV.yx : UV) * repeat_count;
    vec2 dx = dFdx(tiled) * atlas_region.zw;
    vec2 dy = dFdy(tiled) * atlas_region.zw;
    vec2 pixels = vec2(textureSize(atlas, 0));
    float lod = max(0.0, log2(max(max(length(dx * pixels), length(dy * pixels)), 0.0001)));
    vec2 pad = min(vec2(0.5 * exp2(ceil(lod))) / pixels, atlas_region.zw * 0.1);
    vec2 mapped = atlas_region.xy + pad + fract(tiled) * (atlas_region.zw - 2.0 * pad);
    vec4 ink = textureGrad(atlas, mapped, dx, dy);
    ALBEDO = mix(tint.rgb, ink.rgb * tint.rgb, ink_strength);
    ROUGHNESS = 1.0;
}
