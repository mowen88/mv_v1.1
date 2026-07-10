extends CanvasLayer

@onready var health_hud: HBoxContainer = $HealthHUD
const FULL_TEX = preload("res://UI/gameplay/elements/health_node_full.png")
const EMPTY_TEX = preload("res://UI/gameplay/elements/health_node_empty.png")

func _ready() -> void:
	# Connect to both signals
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.player_max_health_changed.connect(_on_player_max_health_changed)

	# Optional: If your player node is ready, you could also call an initial rebuild
	# _rebuild_hud(Player.max_health)

func _rebuild_hud(new_max: int) -> void:
	# 1. Clear old icons
	for child in health_hud.get_children():
		child.queue_free()
	
	# 2. Add new icons based on new_max
	for i in range(new_max):
		var new_mask = TextureRect.new()
		new_mask.texture = FULL_TEX
		new_mask.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_mask.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		
		# Consistent sizing
		new_mask.custom_minimum_size = FULL_TEX.get_size() * 9
		new_mask.scale = Vector2(9, 9)
		
		health_hud.add_child(new_mask)

func _on_player_max_health_changed(new_max: int) -> void:
	_rebuild_hud(new_max)

func _on_player_health_changed(new_health: int) -> void:
	var masks = health_hud.get_children()
	
	for i in range(masks.size()):
		var target = masks[i]
		var was_full = target.texture == FULL_TEX
		
		if i < new_health:
			target.texture = FULL_TEX
		else:
			target.texture = EMPTY_TEX
			
			# If it was full and just turned empty, spawn particles
			if was_full:
				# target.size is the original texture size, multiplied by scale (9)
				# Add half that to find the center of the icon
				var spawn_pos = target.global_position + (target.custom_minimum_size / 2)
				print("Spawning damage particles at: ", spawn_pos)
