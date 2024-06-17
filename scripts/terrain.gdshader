shader_type spatial;

uniform float height_scale = 1.0;
uniform sampler2D height_map;
uniform vec4 albedo_color: source_color = vec4(1.0);
uniform sampler2D albedo_texture;
uniform float albedo_texture_scale = 1.0;
uniform sampler2D normal_map;

varying vec2 tex_position;

void vertex() {
	tex_position = VERTEX.xz + 0.5;
	float height = texture(height_map, tex_position).x;
	VERTEX.y += height * height_scale;
}

void fragment() {
	NORMAL_MAP = texture(normal_map, tex_position).xyz;
	ALBEDO = texture(albedo_texture, tex_position * albedo_texture_scale).xyz * albedo_color.xyz;
}