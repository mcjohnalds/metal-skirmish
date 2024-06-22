shader_type spatial;
render_mode unshaded;
uniform sampler2D screen_texture : source_color, hint_screen_texture;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO = color;
}