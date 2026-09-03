shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float vignette_smoothness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec2 uv = UV - 0.5;
	float dist_sq = dot(uv, uv);
	
	float vignette = smoothstep(0.1, 0.4 + (vignette_smoothness * 0.3), dist_sq * vignette_intensity);
	
	vec3 final_color = vignette_color.rgb;
	float alpha = vignette * vignette_color.a;
	
	COLOR = vec4(final_color, alpha);
}