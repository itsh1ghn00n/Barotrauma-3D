shader_type fog;

uniform float density : hint_range(0, 1, 0.0001) = 1.0;
uniform vec4 albedo : source_color = vec4(1.0); // near fog color
uniform vec4 deep_color : source_color = vec4(0.0, 0.0, 0.2, 1.0); // deep fog color
uniform float vertical_blend_distance = 100.0; // distance from y=0 to full deep_color

uniform vec4 emission : source_color = vec4(0, 0, 0, 1);
uniform float height_falloff = 0.0;
uniform float edge_fade = 0.1;
uniform sampler3D density_texture : hint_default_white;
uniform vec4 fade_plane = vec4(0., 1., 0., -999.);

void fog() {
	// Base density (unchanged)
	DENSITY = density * clamp(exp2(-height_falloff * (WORLD_POSITION.y - OBJECT_POSITION.y)), 0.0, 1.0);
	DENSITY *= texture(density_texture, UVW).r;
	DENSITY *= pow(clamp(-2.0 * SDF / min(min(SIZE.x, SIZE.y), SIZE.z), 0.0, 1.0), edge_fade);

	// Smooth vertical blend
	float height_dist = abs(WORLD_POSITION.y);
	float blend_t = smoothstep(0.0, vertical_blend_distance, height_dist);
	ALBEDO = mix(albedo.rgb, deep_color.rgb, blend_t);
	EMISSION = emission.rgb;

	// Fade plane (unchanged)
	float fade_sharpness = 0.35;
	vec3 fade_plane_origin = fade_plane.xyz * fade_plane.w;
	vec3 pos_rel_to_plane = WORLD_POSITION - fade_plane_origin;
	float fade_mult = max(0., min(1., dot(pos_rel_to_plane, fade_plane.xyz) * fade_sharpness));
	DENSITY *= fade_mult * albedo.a;
}
