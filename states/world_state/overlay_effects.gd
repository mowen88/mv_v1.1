extends CanvasLayer

@onready var screen_rect: ColorRect = $ColorRect

func _ready() -> void:
	SignalBus.flash_screen.connect(_flash_screen)
	SignalBus.death_screen_fade.connect(_fade_Screen)

func _flash_screen(color: Color = Color.WHITE, duration: float = 0.3) -> void:
	var tween = create_tween()
	
	# Start full alpha
	screen_rect.modulate = color
	screen_rect.visible = true
	
	# Fade alpha
	tween.tween_property(screen_rect, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): screen_rect.visible = false)

func _fade_Screen(color:Color = Color.WHITE, duration:float = 1.0) -> void:
	
	var tween = create_tween()
	screen_rect.color = color
	# Start zero alpha
	screen_rect.modulate.a = 0.0
	screen_rect.visible = true
	
	# Fade in screen color
	tween.tween_property(screen_rect, "modulate:a", color.a, duration)
