extends HBoxContainer

@onready var health_hud: HBoxContainer = self

const HEALTH_FULL_TEX = preload("res://UI/gameplay/elements/health_node_full.png")
const HEALTH_EMPTY_TEX = preload("res://UI/gameplay/elements/health_node_empty.png")

func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.player_max_health_changed.connect(_on_player_max_health_changed)

func _on_player_max_health_changed(new_max: int) -> void:
	_rebuild_health_hud(new_max)

func _rebuild_health_hud(new_max: int) -> void:
	for child in health_hud.get_children():
		child.queue_free()
	
	for i in range(new_max):
		var new_node = TextureRect.new()
		new_node.texture = HEALTH_FULL_TEX
		new_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_node.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		new_node.custom_minimum_size = HEALTH_FULL_TEX.get_size() * 9
		new_node.scale = Vector2(9, 9)
		
		health_hud.add_child(new_node)

func _on_player_health_changed(new_health: int) -> void:
	var nodes = health_hud.get_children()
	
	for i in range(nodes.size()):
		var target = nodes[i]
		var desired_texture = HEALTH_FULL_TEX if i < new_health else HEALTH_EMPTY_TEX
		
		if target.texture != desired_texture:
			target.texture = desired_texture
