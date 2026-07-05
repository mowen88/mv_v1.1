extends Node

# Map shader mode integers to strings
const TRANSITION_MODES: Dictionary = {
	"fade": 0,
	"grid": 1,
	"curtain":2,
	"blinds":3
}

@onready var color_rect = $ColorRect

func _ready() -> void:
	# Keep the overlay hidden on boot
	if color_rect:
		color_rect.color.a = 0.0
		color_rect.visible = false

# Transition func with default parameters that can be overridden
func transition(on_mid_transition: Callable, \
in_duration: float = 0.2, \
out_duration: float = 0.5, \
in_mode: String = "fade",
out_mode: String = "fade") -> void:
	
	if InputManager.input_lock or not color_rect:
		return

	color_rect.visible = true
	InputManager.input_lock = true
	
	# Transition in - progress from 0 to 1
	_set_transition_mode(in_mode)
	var tween_in: Tween = create_tween()
	tween_in.tween_method(_update_progress, 0.0, 1.0, in_duration)
	await tween_in.finished
	
	# Mid-point function call
	if on_mid_transition.is_valid():
		await on_mid_transition.call()
		
	# Transition out - progress from 1 to 0
	_set_transition_mode(out_mode)
	var tween_out: Tween = create_tween()
	tween_out.tween_method(_update_progress, 1.0, 0.0, out_duration)
	await tween_out.finished
	
	# Unlock input and set visible to false to finish
	color_rect.visible = false
	InputManager.input_lock = false

func _set_transition_mode(mode_name: String) -> void:
	if color_rect.material is ShaderMaterial:
		var mode_id = TRANSITION_MODES.get(mode_name.to_lower(), 0)
		color_rect.material.set_shader_parameter("mode", mode_id)

func _update_progress(progress: float) -> void:
	
	if color_rect and color_rect.material:
		color_rect.material.set_shader_parameter("progress", progress)
