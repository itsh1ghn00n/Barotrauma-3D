shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform float water_level: hint_range(0.0, 1.0) = 1.0;
uniform vec2 water_height_range = vec2(1.9, 0.39);

uniform float current_angle: hint_range(0.0,360.0) = 90.0;

varying vec3 world_pos;
varying vec3 local_pos;

group_uniforms Visuals;
uniform vec4 liquid_color: source_color = vec4(0.7, 0.1, 0.6, 1.0);

vec3 rotate_about_axis(vec3 v, vec3 axis, float angle) {
	axis = normalize(axis);
	float cosA = cos(angle);
	float sinA = sin(angle);
	return v * cosA + cross(axis, v) * sinA + axis * dot(axis, v) * (1.0 - cosA);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
	//VERTEX.y *= water_level;
	//VERTEX.y += -1.5 + (water_level);
}

void fragment() {
	vec3 rot_axis = vec3(1,0,0);

	vec3 rotation = rotate_about_axis(local_pos, rot_axis, radians(current_angle));

	float diff = local_pos.y - world_pos.y;
	float add = diff + rotation.y;

	float remapped_water = mix(water_height_range.x,water_height_range.y, water_level);

	float mask = step(remapped_water, world_pos.y + add * 0.5);

	ALPHA = mask;
	ALBEDO = liquid_color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
