extends TouchScreenButton

func _ready() -> void:
	visible = false
	#modulate.a = 0.0
	
	SignalBus.show_interaction_prompt.connect(_show_prompt)
	SignalBus.hide_interaction_prompt.connect(_hide_prompt)

func _show_prompt() -> void:
	#text = text
	visible = true
	#var tween = create_tween()
	#tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _hide_prompt() -> void:
	#var tween = create_tween()
	#tween.tween_property(self, "modulate:a", 0.0, 0.3)
	#await tween.finished
	visible = false
