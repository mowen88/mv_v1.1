class_name DeathHazeCanvas
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var haze_tween: Tween

func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	SignalBus.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(val: int)-> void:
	if val <= 1:
		visible = true
		start_pulsing()
	else:
		visible = false
		stop_pulsing()

func start_pulsing() -> void:
	if haze_tween and haze_tween.is_running():
		haze_tween.kill()
		
	var material = color_rect.material as ShaderMaterial
	if not material:
		return
		
	haze_tween = create_tween().set_loops()
	
	haze_tween.tween_method(
		func(val): material.set_shader_parameter("vignette_intensity", val), 
		1.2, 1.0, 1.0
	)
	haze_tween.tween_method(
		func(val): material.set_shader_parameter("vignette_intensity", val), 
		1.0, 1.2, 1.0
	)

func stop_pulsing() -> void:
	if haze_tween and haze_tween.is_running():
		haze_tween.kill()
	
	var material = color_rect.material as ShaderMaterial
	if material:
		var fade_out = create_tween()
		fade_out.tween_method(
			func(val): material.set_shader_parameter("vignette_intensity", val),
			material.get_shader_parameter("vignette_intensity"), 0.0, 0.5
		)
