shader_type canvas_item;

uniform bool flash_active = false;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);
    // If flashing, output the flash_color but keep the original transparency (alpha)
    if (flash_active) {
        COLOR = vec4(flash_color.rgb, current_pixel.a);
    } else {
        COLOR = current_pixel;
    }
}