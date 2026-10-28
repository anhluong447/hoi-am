shader_type canvas_item;
render_mode unshaded;

// Depth-of-field stand-in for the far plate: sample the CanvasGroup buffer from a
// lower mip level. The group must have use_mipmaps enabled.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float lod = 3.0;

void fragment() {
    vec4 c = textureLod(screen_texture, SCREEN_UV, lod);
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }
    COLOR *= c;
}
