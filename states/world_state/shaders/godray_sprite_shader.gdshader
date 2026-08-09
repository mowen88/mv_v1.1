shader_type canvas_item;

void fragment() {
	// Top (UV.y = 0.0) is solid white with 0 alpha (completely clear)
	vec4 top_color = vec4(1.0, 1.0, 1.0, 0.0);
	
	// Bottom (UV.y = 1.0) is solid white with 1 alpha (completely solid)
	vec4 bottom_color = vec4(1.0, 1.0, 1.0, 1.0);
	
	// Mix them based on vertical screen position
	COLOR = mix(top_color, bottom_color, UV.y);
}