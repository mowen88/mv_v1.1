shader_type canvas_item;

uniform bool flash_active = false;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Capture the node's modulate/vertex color safely before it gets overwritten
varying vec4 custom_modulate;

void vertex() {
    custom_modulate = COLOR;
}

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);
    
    vec4 final_color;
    if (flash_active) {
        final_color = vec4(flash_color.rgb, current_pixel.a);
    } else {
        final_color = current_pixel;
    }
    
    // Apply your flash/texture result, then multiply cleanly by the captured modulate
    COLOR = final_color * custom_modulate;
}