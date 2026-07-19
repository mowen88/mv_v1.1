extends CanvasLayer

@onready var energy_hud: HBoxContainer = $EnergyHUD
@onready var health_hud: HBoxContainer = $HealthHUD
@onready var zone_label: Label = $ZoneLabel

# Health Textures
const HEALTH_FULL_TEX = preload("res://UI/gameplay/elements/health_node_full.png")
const HEALTH_EMPTY_TEX = preload("res://UI/gameplay/elements/health_node_empty.png")

# Energy Textures
const ENERGY_FULL_TEX = preload("res://UI/gameplay/elements/energy_full.png") 
const ENERGY_EMPTY_TEX = preload("res://UI/gameplay/elements/energy_empty.png")

func _ready() -> void:

	# Health
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.player_max_health_changed.connect(_on_player_max_health_changed)

	# Energy
	SignalBus.player_energy_changed.connect(_on_energy_changed)
	SignalBus.player_max_energy_changed.connect(_on_max_energy_changed)

# Energy logic
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
		
		# Determine what the texture SHOULD be based on the new energy
		var desired_texture = ENERGY_FULL_TEX if i < new_energy else ENERGY_EMPTY_TEX
		
		# If the texture needs to change, update it and spawn a flash
		if target.texture != desired_texture:
			target.texture = desired_texture
			
			var spawn_pos = target.global_position + (target.custom_minimum_size / 2)
			_spawn_flash(spawn_pos)


# Health logic
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
		
		# Determine what the texture SHOULD be based on the new health
		var desired_texture = HEALTH_FULL_TEX if i < new_health else HEALTH_EMPTY_TEX
		
		# If the texture needs to change, update it and spawn a flash
		if target.texture != desired_texture:
			target.texture = desired_texture
			
			var spawn_pos = target.global_position + (target.custom_minimum_size / 2)
			_spawn_flash(spawn_pos)


# Particle effects
func _spawn_flash(position: Vector2) -> void:
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	var base_size = 3 * 9
	flash.size = Vector2(base_size, base_size)
	flash.pivot_offset = flash.size / 2
	flash.global_position = position - (flash.size / 2)
	
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "scale", Vector2(9, 9), 0.2).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_callback(flash.queue_free)
