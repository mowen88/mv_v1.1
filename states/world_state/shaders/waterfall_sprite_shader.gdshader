shader_type canvas_item;
render_mode blend_mix;

// --- Uniforms ---
uniform vec4 deep_color : source_color = vec4(0.1, 0.4, 0.5, 1.0);  // Dark retro blue
uniform vec4 bright_color : source_color = vec4(0.4, 0.8, 4.0, 1.0); // Light blue water
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);   // Pure white pixel streaks
uniform float fall_speed : hint_range(1.0, 45.0) = 12.0;           // Snappy pixel fall speed
uniform float pixel_density : hint_range(4.0, 64.0) = 16.0;        // Controls chunky retro pixel size

// Retro pseudo-random hash function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	// Snap UV coordinates to a low-res pixel grid
	vec2 pixel_uv = floor(UV * pixel_density) / pixel_density;
	
	// Create staggered vertical columns
	float column = floor(pixel_uv.x * pixel_density);
	float speed_offset = random(vec2(column, 1.0)) * 20.0;
	
	// Discrete stepping for retro frame-by-frame movement feel
	float time_step = floor(TIME * fall_speed + speed_offset);
	
	// Generate chunky blocky noise pattern moving down
	float n = random(vec2(pixel_uv.x, pixel_uv.y * 2.0 - time_step / pixel_density));
	
	// Quantize the colors into harsh retro thresholds (no smooth gradients)
	vec4 final_color = deep_color;
	if (n > 0.4) {
		final_color = bright_color;
	}
	if (n > 0.75) {
		final_color = foam_color;
	}
	
	// Apply original sprite texture mask
	vec4 tex_col = texture(TEXTURE, UV);
	
	COLOR = final_color;
	COLOR.a *= tex_col.a;
}