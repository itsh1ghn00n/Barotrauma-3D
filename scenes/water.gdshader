shader_type spatial;

uniform float fill_level : hint_range(0.0, 1.0) = 0.5; // 0 = empty, 1 = full
uniform vec4 water_color : source_color = vec4(0.0, 0.3, 0.8, 1.0);
uniform vec4 empty_color : source_color = vec4(0.1, 0.1, 0.1, 0.0);
uniform float smoothness : hint_range(0.0, 0.1) = 0.02; // soften edge

void fragment() {
    // Transform the current fragment position into WORLD space
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Get world up direction (constant in world space)
    vec3 world_up = vec3(0.0, 1.0, 0.0);
    
    // Define your "fill plane" height in world space
    // You can offset it relative to object origin
    float object_height = 1.0; // scale this to match your mesh height
    float fill_height = mix(0.0, object_height, fill_level);
    
    // Compare how high the pixel is relative to fill plane
    float height_diff = dot(world_pos, world_up) - fill_height;

    // Smooth transition (edge softness)
    float t = smoothstep(-smoothness, smoothness, -height_diff);
    
    // Blend between empty and water color
    ALBEDO = mix(empty_color.rgb, water_color.rgb, t);
    ALPHA = mix(empty_color.a, water_color.a, t);
}
