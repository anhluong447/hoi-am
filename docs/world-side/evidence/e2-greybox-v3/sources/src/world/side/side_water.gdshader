shader_type canvas_item;
// Water layer: phase tint plus a slow horizontal ripple. wave_time is driven
// by the room (deterministic; frozen under reduced motion), not TIME.

uniform vec4 tint : source_color = vec4(1.0);
uniform float strength = 0.6;
uniform float wave_time = 0.0;
uniform float amplitude = 0.003;
uniform float frequency = 18.0;
varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.y * frequency + wave_time * 1.3) * amplitude;
	vec4 base = texture(TEXTURE, uv) * vertex_color;
	float shimmer = 0.04 * sin(uv.x * 40.0 + uv.y * 12.0 - wave_time * 2.0);
	base.rgb *= mix(vec3(1.0), tint.rgb, strength) * (1.0 + shimmer);
	COLOR = base;
}
