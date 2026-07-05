shader_type canvas_item;

// Mode: 0 = Alpha, 1 = Grid, 2 = Curtains, 3 = Blinds
uniform int mode : hint_range(0, 3) = 0; 
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float boxes_vertical = 9.0; 
uniform vec4 box_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float alpha = 0.0;

    if (mode == 0) {
        alpha = progress;
    } 
    else if (mode == 1) {
        float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
        vec2 grid_size = vec2(boxes_vertical * aspect_ratio, boxes_vertical);
        vec2 cell_uv = fract(UV * grid_size);
        vec2 center_dist = abs(cell_uv - vec2(0.5));
        float max_dist = max(center_dist.x, center_dist.y);
        alpha = (max_dist < progress * 0.5) ? 1.0 : 0.0;
    }
    else if (mode == 2) {
        float dist_from_center = abs(UV.x - 0.5);
        float threshold = 0.5 * (1.0 - progress);
        alpha = (dist_from_center < threshold) ? 0.0 : 1.0;
    }
    else if (mode == 3) {
        // --- Mode 3: Vertical Blinds ---
        // We only care about the X axis to create vertical strips
        float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
        // Use aspect ratio so the strips are vertical rectangles rather than squares
        float grid_count = boxes_vertical * aspect_ratio;
        
        float cell_x = fract(UV.x * grid_count);
        float dist_from_center = abs(cell_x - 0.5);
        
        // Expansion logic
        alpha = (dist_from_center < progress * 0.5) ? 1.0 : 0.0;
    }

    COLOR = vec4(box_color.rgb, alpha);
}