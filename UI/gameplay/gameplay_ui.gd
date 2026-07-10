extends CanvasLayer

@onready var health_hud: HBoxContainer = $HealthHUD
const FULL_TEX = preload("res://UI/gameplay/elements/health_node_full.png")
const EMPTY_TEX = preload("res://UI/gameplay/elements/health_node_empty.png")

func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.player_max_health_changed.connect(_on_player_max_health_changed)

func _rebuild_hud(new_max: int) -> void:
	for child in health_hud.get_children():
		child.queue_free()
	
	for i in range(new_max):
		var new_node = TextureRect.new()
		new_node.texture = FULL_TEX
		new_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_node.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		
		new_node.custom_minimum_size = FULL_TEX.get_size() * 9
		new_node.scale = Vector2(9, 9)
		
		health_hud.add_child(new_node)

func _on_player_max_health_changed(new_max: int) -> void:
	_rebuild_hud(new_max)

func _on_player_health_changed(new_health: int) -> void:
	var nodes = health_hud.get_children()
	
	for i in range(nodes.size()):
		var target = nodes[i]
		var was_full = target.texture == FULL_TEX
		
		if i < new_health:
			target.texture = FULL_TEX
		else:
			target.texture = EMPTY_TEX
			
			if was_full:
				var spawn_pos = target.global_position + (target.custom_minimum_size / 2)
				_spawn_flash(spawn_pos)

func _spawn_flash(position: Vector2) -> void:
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	var base_size = 3 * Constants.UI_SCALE
	flash.size = Vector2(base_size, base_size)
	flash.pivot_offset = flash.size / 2
	flash.global_position = position - (flash.size / 2)
	
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "scale", Vector2(Constants.UI_SCALE, Constants.UI_SCALE), 0.2).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_callback(flash.queue_free)
