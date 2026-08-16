extends CanvasLayer

@export var coin_collect_sound: AudioStream

@onready var energy_hud: HBoxContainer = $EnergyHUD
@onready var health_hud: HBoxContainer = $HealthHUD
@onready var coin_hud: Label = $CoinContainer/CoinLabel
@onready var zone_label: Label = $ZoneLabel
@onready var tutorial_message: Label = $TutorialMessage

@onready var banner_initial_x = zone_label.position.x

# Health Textures
const HEALTH_FULL_TEX = preload("res://UI/gameplay/elements/health_node_full.png")
const HEALTH_EMPTY_TEX = preload("res://UI/gameplay/elements/health_node_empty.png")

# Energy Textures
const ENERGY_FULL_TEX = preload("res://UI/gameplay/elements/energy_full.png") 
const ENERGY_EMPTY_TEX = preload("res://UI/gameplay/elements/energy_empty.png")

var displayed_coins: int = 0
var coin_tween: Tween
var banner_tween: Tween
var message_tween: Tween

func _ready() -> void:
	
	# Messages
	SignalBus.zone_banner_requested.connect(_on_zone_banner_requested)
	SignalBus.tutorial_message_requested.connect(_on_tutorial_message_requested)
	
	# Health
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.player_max_health_changed.connect(_on_player_max_health_changed)

	# Energy
	SignalBus.player_energy_changed.connect(_on_energy_changed)
	SignalBus.player_max_energy_changed.connect(_on_max_energy_changed)
	
	# Coins
	SignalBus.player_coins_changed.connect(_on_coins_changed)

func _on_tutorial_message_requested(message:String) -> void:
	# Only run tween if there is not one currently active
	if message_tween and message_tween.is_running():
		return

	tutorial_message.text = message
	tutorial_message.modulate.a = 0.0
	tutorial_message.visible = true
	
	message_tween = create_tween()
	# Fade in
	message_tween.tween_property(tutorial_message, "modulate:a", 1.0, 0.5)
	# Wait
	message_tween.tween_interval(2.0)
	# Fade out
	message_tween.tween_property(tutorial_message, "modulate:a", 0.0, 0.5)
	message_tween.tween_callback(func(): tutorial_message.visible = false)

func _on_coins_changed(new_total_coins: int) -> void:

	# If a tween is already running, kill it so we can start a new count target
	if coin_tween and coin_tween.is_running():
		coin_tween.kill()
	
	
	coin_tween = create_tween()
	
	# Tween the 'displayed_coins' variable integer value up to the new total
	# Duration scales slightly based on how many coins are being added
	var difference = abs(new_total_coins - displayed_coins)
	 # Update rate at roughly 0.1s per coin, capped to take 2 secs max to update
	var anim_duration = clamp(difference * 0.1, 0.1, 2.0)
	
	coin_tween.tween_method(
		func(val: int):
			# Only play effect when number changes in the UI
			if val != displayed_coins:
				AudioManager.play_sfx(coin_collect_sound,1,0.1)
			displayed_coins = val
			coin_hud.text = str(displayed_coins),
		displayed_coins,
		new_total_coins,
		anim_duration
	).set_trans(Tween.TRANS_LINEAR)

func _on_zone_banner_requested(zone_name:String, show_banner:bool) -> void:
	# Instantly kill any ongoing animation or pending delay from a previous room
	if banner_tween:
		banner_tween.kill()
	
	if not show_banner or zone_name == "":
		zone_label.visible = false
		return

	# Reset visual state immediately in case an old one was partway through fading out
	zone_label.text = zone_name
	zone_label.position.x = banner_initial_x
	zone_label.modulate.a = 0.0  # Start invisible, or 1.0 if you want it to pop
	zone_label.visible = false

	var target_x = banner_initial_x - zone_label.size.x

	banner_tween = create_tween()
	
	# 1. Wait a sec before starting the animation (safely killed if you leave early)
	banner_tween.tween_interval(1.0)
	
	# 2. Make visible right as the slide starts
	banner_tween.tween_callback(func(): zone_label.visible = true)
	
	# 3. Slide in / Fade in
	banner_tween.tween_property(zone_label, "position:x", target_x, 1.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	banner_tween.parallel().tween_property(zone_label, "modulate:a", 1.0, 0.5)
	
	# 4. Hold visible for 2 seconds
	banner_tween.tween_interval(2.0)
	
	# 5. Fade out and hide
	banner_tween.tween_property(zone_label, "modulate:a", 0.0, 0.5)
	banner_tween.tween_callback(func(): zone_label.visible = false)

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
