shader_type canvas_item;

uniform sampler2D screen_texture:
		hint_screen_texture, filter_nearest, repeat_disable;
uniform sampler2D dirt_texture:
		filter_linear, repeat_enable;

bool fequal(float a, float b) {
	return abs(a - b) < 0.0001;
}

vec3 blend_soft_light(vec3 base, vec3 blend) {
	return mix(
			sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend), 
			2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
			step(base, vec3(0.5))
	);
}

vec3 dirt(vec3 color, vec2 uv) {
	vec3 blend = vec3(0.5) + texture(dirt_texture, uv).rgb * 0.5;
	return blend_soft_light(color, blend);
}

float rand_gold(vec2 uv, float seed) {
	float phi = 1.61803398874989484820459;
	return fract(tan(distance(uv * phi, uv) * seed) * uv.x);
}

float rand_sin(vec2 uv, float seed) {
	vec3 v = vec3(uv, seed);
	vec3 w = vec3(12.9898, 78.233, 42.953);
	return fract(sin(dot(v, w)) * 43758.5453123);
}

vec3 vignette(vec3 color, vec2 uv) {
	float d = distance(uv, vec2(0.5)) * 1.7;
	float a = smoothstep(0.0, 1.5, d) * 0.3;
	return blend_soft_light(color, color + vec3(a));
	//return clamp(mix(color, vec3(1.0), a), 0.0, 1.0);
}

vec3 film_grain(vec3 color, vec2 uv) {
	vec2 v = vec2(12.9898, 78.233 + TIME);
	float noise = fract(sin(dot(uv, v)) * 43758.5453);
	 color.rgb += (1.0 - sqrt(color.r)) * noise * 0.1;
	return clamp(color, 0.0, 1.0);
}

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 uv_1 = SCREEN_UV;
	vec2 uv_2 = uv_1 * vec2(1.0, aspect_ratio);
	vec3 col = texture(screen_texture, uv_1).xyz;
	col = dirt(col, uv_2);
	col = vignette(col, uv_1);
	col = film_grain(col, uv_1);
	COLOR.rgb = col;
}
