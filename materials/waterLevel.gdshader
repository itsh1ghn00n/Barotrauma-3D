shader_type spatial;
render_mode cull_front, shadows_disabled;

uniform float water_level:hint_range(0.0,1.0)=1.0;
uniform vec2 water_height_range=vec2(0,1);
uniform float current_angle:hint_range(0.0,360.0)=90.0;

group_uniforms Visuals;
uniform vec4 liquid_color:source_color=vec4(0.7,0.1,0.6,1.0);
uniform vec4 foam_color:source_color=vec4(0.9,0.8,0.9,1.0);
uniform float foam_line:hint_range(0.0,1.0)=0.15;

varying vec3 world_pos;
varying vec3 world_normal;
varying lowp vec3 world_up;

mat2 rotate2D(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(
        vec2(c, s),     // column 1
        vec2(-s, c)     // column 2
    );
}

void vertex(){
	world_pos = mat3(MODEL_MATRIX)*VERTEX;
	world_normal=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
	world_up = normalize((MODEL_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
}


void fragment() {
	//float angle = radians(current_angle);;
	
	//vec2 rotated_pos = rotate2D(angle) * world_pos.xy;
	
	//vec2 rotated_coeff = rotate2D(angle) * rotated_pos;
	
	//float wave = dot(rotated_pos, vec2(1.0, 0.0));
	
	float liquid_line = mix(water_height_range.x, water_height_range.y, water_level);
	vec3 foam_mix = mix(liquid_color.rgb, foam_color.rgb, world_up.y);
	vec3 normal_foam = mix (NORMAL, world_pos, water_level);
	
	if (water_level == 1.0) {
		ALBEDO = foam_mix;
		ALPHA = liquid_color.w;
		NORMAL = normal_foam;
	}
	else if (world_pos.y > liquid_line) {
		discard;
	}
	ALBEDO = foam_mix;
	ALPHA = liquid_color.w;
	NORMAL = normal_foam;
}

//void light() 
//{
	///// Liquid "glow" when held against light. 
	//float d  = dot(-VIEW, LIGHT);
	//float dd = smoothstep(0.0, 1.0, d);
	//dd = pow(dd, 5.0);
	//DIFFUSE_LIGHT = (dd -BACKLIGHT.z * d) * liquid_color.rgb;
//}
