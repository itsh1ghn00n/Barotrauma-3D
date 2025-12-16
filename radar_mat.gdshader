shader_type canvas_item;

uniform float sweep_angle:hint_range(0.0, 6.28318);
uniform float line_thickness = 0.02;
uniform float radius = 0.48;

uniform vec4 line_color     : source_color = vec4(0.2, 1.0, 0.2, 1.0);
uniform vec4 ring_color : source_color = vec4(0.1, 0.5, 0.1, 0.4);
uniform vec4 edge_color : source_color = vec4(0.1, 0.5, 0.1, 0.4);

uniform vec4 shallow_color : source_color = vec4(0.2, 0.6, 0.2, 1.0);
uniform vec4 background_color       : source_color = vec4(0.0, 0.15, 0.0, 1.0);

uniform float ring_spacing = 0.15;
uniform float ring_thickness = 0.01;

//Sonar Viewport Tex
uniform sampler2D sonar_tex;


void fragment() {
	// Radar-space
	vec2 radar_uv = UV * 2.0 - 1.0;
	float dist = length(radar_uv);

	if (dist > radius) discard;

	// Angle
	float angle = atan(radar_uv.y, radar_uv.x);
	if (angle < 0.0) angle += TAU;

	// -------- Sonar background --------
	vec3 cam_col = texture(sonar_tex, UV).rgb;
	float cam_value = dot(cam_col, vec3(0.299, 0.587, 0.114));

	float range_fade = smoothstep(radius, radius - 0.25, dist);
	cam_value = smoothstep(0.05, 0.5, cam_value) * range_fade;

	vec3 color = background_color.rgb;
	color += shallow_color.rgb * cam_value;

	// -------- Range rings --------
	float ring = abs(fract(dist / ring_spacing) - 0.5);
	float ring_mask = smoothstep(ring_thickness, 0.0, ring);
	color += ring_color.rgb * ring_mask * ring_color.a;

	// -------- Sweep line --------
	float diff = abs(angle - sweep_angle);
	diff = min(diff, TAU - diff);
	float sweep = smoothstep(line_thickness, 0.0, diff);
	color += line_color.rgb * sweep;

	COLOR = vec4(color, 1.0);
}
