shader_type spatial;
render_mode cull_disabled, unshaded;

uniform sampler2D atlas : source_color, filter_nearest_mipmap;
uniform vec4 atlas_region;
uniform float strength;
uniform float speed;
uniform vec4 tint : source_color;

void fragment() {
    vec2 wave = vec2(sin(UV.y * 25.0 + TIME * speed), cos(UV.x * 19.0 - TIME * speed));
    vec2 local = fract(UV * 3.0 + wave * strength);
    ALBEDO = texture(atlas, atlas_region.xy + local * atlas_region.zw).rgb * tint.rgb;
}
