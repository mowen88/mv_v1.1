extends HBoxContainer

@onready var energy_hud: HBoxContainer = self

const ENERGY_FULL_TEX = preload("res://UI/gameplay/elements/energy_full.png") 
const ENERGY_EMPTY_TEX = preload("res://UI/gameplay/elements/energy_empty.png")

func _ready() -> void:
	SignalBus.player_energy_changed.connect(_on_energy_changed)
	SignalBus.player_max_energy_changed.connect(_on_max_energy_changed)

func _on_max_energy_changed(new_max: int) -> void:
	_rebuild_energy_hud(new_max)

func _rebuild_energy_hud(new_max: int) -> void:
	for child in energy_hud.get_children():
		child.queue_free()
	
	for i in range(new_max):
		var new_node = TextureRect.new()
		new_node.texture = ENERGY_FULL_TEX
		new_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_node.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		new_node.custom_minimum_size = ENERGY_FULL_TEX.get_size() * 9
		new_node.scale = Vector2(9, 9)
		
		energy_hud.add_child(new_node)

func _on_energy_changed(new_energy: int) -> void:
	var nodes = energy_hud.get_children()
	
	for i in range(nodes.size()):
		var target = nodes[i]
		var desired_texture = ENERGY_FULL_TEX if i < new_energy else ENERGY_EMPTY_TEX
		
		if target.texture != desired_texture:
			target.texture = desired_texture
