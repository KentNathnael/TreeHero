shader_type canvas_item;

uniform bool active = false;

void fragment() {
	vec4 tint_color = texture(TEXTURE, UV);
	if (active) {
		tint_color.rgb = vec3(1.0, 1.0, 1.0); // Ubah jadi putih solid
	}
	COLOR = tint_color;
}