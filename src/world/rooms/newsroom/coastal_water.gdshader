shader_type spatial;

uniform vec4 tint : source_color;
uniform float strength;
uniform float speed;
varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float shimmer = pow(max(0.0, sin(world_position.x * 8.0 + sin(world_position.z * 4.0 + TIME * speed))), 12.0);
    ALBEDO = tint.rgb + vec3(shimmer * strength);
    ROUGHNESS = 0.65;
}
