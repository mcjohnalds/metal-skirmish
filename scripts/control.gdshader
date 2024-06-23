shader_type canvas_item;

uniform sampler2D gradient_texture;

vec4 blend_soft_light(vec4 base, vec4 blend) {
	return mix(
			sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend), 
			2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
			step(base, vec4(0.5))
	);
}

vec4 banding(vec4 color) {
	// Levels
	float l = 32.0;
	// Lowering the a param below 1.0 means more shades of black, fewer shades
	// of white
	float a = 0.8;
	return pow(round(pow(color, vec4(a)) * l) / l, 1.0 / vec4(a));
}

void fragment(){
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec4 gradient_tex = texture(gradient_texture, SCREEN_UV.xy * vec2(1.0, aspect_ratio));
	COLOR = blend_soft_light(COLOR, COLOR + gradient_tex);
	COLOR = COLOR * vec4(210.0 / 255.0, 221.0 / 255.0, 224.0 / 255.0, 1.0);
	//COLOR = banding(COLOR);
}
