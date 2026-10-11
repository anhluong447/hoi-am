shader_type canvas_item;

uniform float radius = 0.0;
varying vec4 tint;

void vertex() {
    tint = COLOR;
}

void fragment() {
    // Premultiply samples before mixing, then restore straight alpha for blend_mix.
    // This blurs only the transparent glyph viewport, never paper or world pixels.
    vec4 sum = vec4(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float weight = (x == 0 ? 2.0 : 1.0) * (y == 0 ? 2.0 : 1.0);
            vec4 sample_color = texture(TEXTURE, UV + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * radius);
            sum += vec4(sample_color.rgb * sample_color.a, sample_color.a) * weight;
        }
    }
    sum /= 16.0;
    COLOR = tint * vec4(sum.rgb / max(sum.a, 0.00001), sum.a);
}
