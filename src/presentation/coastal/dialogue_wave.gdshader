shader_type canvas_item;

uniform float phase = 0.0;
uniform float amplitude = 0.0;
uniform float period;
uniform float secondary_period;
uniform float frequency;
uniform float secondary_amplitude;
uniform float shimmer_strength;
uniform float shimmer_width;
varying vec4 tint;

void vertex() {
    tint = COLOR;
}

void fragment() {
    float primary = sin(UV.x * frequency * TAU + phase * TAU / period);
    float secondary = sin(UV.x * (frequency + 1.0) * TAU - phase * TAU / secondary_period);
    vec2 shifted = UV + vec2(0.0, (primary + secondary * secondary_amplitude) * amplitude * TEXTURE_PIXEL_SIZE.y);
    vec4 ink = texture(TEXTURE, shifted);
    float sweep = fract(phase / secondary_period);
    float light = 1.0 - smoothstep(0.0, shimmer_width, abs(UV.x - sweep));
    ink.rgb += light * shimmer_strength * min(amplitude, 1.0);
    COLOR = ink * tint;
}
