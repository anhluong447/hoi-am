shader_type spatial;
render_mode cull_disabled, unshaded;

uniform sampler2D atlas : source_color, filter_nearest_mipmap;
uniform vec4 atlas_region;
uniform float strength;
uniform float speed;
uniform float wave_time;
uniform vec4 tint : source_color;

void fragment() {
    vec2 wave = vec2(sin(UV.y * 25.0 + wave_time * speed), cos(UV.x * 19.0 - wave_time * speed));
    vec2 tiled = UV * 3.0 + wave * strength;
    vec2 dx = dFdx(tiled) * atlas_region.zw;
    vec2 dy = dFdy(tiled) * atlas_region.zw;
    vec2 pixels = vec2(textureSize(atlas, 0));
    float lod = max(0.0, log2(max(max(length(dx * pixels), length(dy * pixels)), 0.0001)));
    vec2 pad = min(vec2(max(8.0, 0.5 * exp2(ceil(lod)))) / pixels, atlas_region.zw * 0.1);
    vec2 mirrored = 1.0 - abs(fract(tiled * 0.5) * 2.0 - 1.0);
    vec2 mapped = atlas_region.xy + pad + mirrored * (atlas_region.zw - 2.0 * pad);
    ALBEDO = textureGrad(atlas, mapped, dx, dy).rgb * tint.rgb;
}
