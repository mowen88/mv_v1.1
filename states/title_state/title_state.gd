extends Node2D

@onready var character_image: TextureRect = $CanvasLayer/CharacterImage
# Grab a reference to our new modular, child menu manager component
@onready var menu_manager: Control = $CanvasLayer/MenuAnchor/MenuManager

func _ready() -> void:
	# Keep inputs locked while the initial title splash plays out

	await get_tree().create_timer(0.2).timeout
	_tween_in_character()
	
	# Wait for the character art animation to finish before waking up the menu system
	await get_tree().create_timer(1.0).timeout
	# Open the menu manager
	menu_manager._initialize_menu("MainMenu")

func _tween_in_character() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(character_image, "position:x", 0, 1.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
