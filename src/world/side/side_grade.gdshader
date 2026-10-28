shader_type canvas_item;
// Single-pass world grade on a CanvasLayer below the UI: saturation, gentle
// contrast, soft vignette and an interleaved-gradient dither against banding.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;
uniform float saturation = 1.05;
uniform float contrast = 1.04;
uniform float vignette = 0.18;
uniform float dither = 1.0;

void fragment() {
	vec3 color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	color = mix(vec3(luma), color, saturation);
	color = (color - 0.5) * contrast + 0.5;
	vec2 centered = SCREEN_UV - 0.5;
	color *= 1.0 - vignette * dot(centered, centered) * 2.0;
	float noise = fract(52.9829189 * fract(dot(FRAGCOORD.xy, vec2(0.06711056, 0.00583715))));
	color += (noise - 0.5) * dither / 255.0;
	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
