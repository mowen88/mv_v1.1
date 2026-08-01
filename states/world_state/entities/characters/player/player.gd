class_name Player
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var energy_component: EnergyComponent = $EnergyComponent

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent

@onready var sword = $SwordScene

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer


var last_safe_position: Vector2 = Vector2.ZERO
var jump_counter: int = 0
		
func _ready() -> void:	

	health_component.died.connect(_on_death)
	health_component.health_changed.connect(func(val):SignalBus.player_health_changed.emit(val))
	health_component.max_health_changed.connect(func(val):SignalBus.player_max_health_changed.emit(val))
	
	energy_component.energy_changed.connect(func(val): SignalBus.player_energy_changed.emit(val))
	energy_component.max_energy_changed.connect(func(val): SignalBus.player_max_energy_changed.emit(val))
	
	SignalBus.player_max_health_changed.emit(health_component.max_health)
	SignalBus.player_health_changed.emit(health_component.current_health)

	SignalBus.player_max_energy_changed.emit(energy_component.max_energy)
	SignalBus.player_energy_changed.emit(energy_component.current_energy)
	
	SignalBus.player_energy_gained.connect(_gain_energy)
	SignalBus.player_respawn.connect(_update_respawn_point)
	SignalBus.hit_hazard.connect(_on_hit_hazard)
	
	# Get swipe signal
	SignalBus.swipe_down_detected.connect(_on_swipe_down)

func _on_swipe_down() -> void:
	if InputManager.input_lock:
		return
	
	var valid_states = ["Idle", "Run"]
	if fsm.current_state.name in valid_states and is_on_floor():
		# Stop player sticking to wall in run state fix by bouncing away slightly
		if is_on_wall():
			velocity.x = 25 * -move_component.facing
		# Disable the platform collisions, wait short time and reenable
		set_collision_mask_value(2, false)
		await get_tree().create_timer(0.1).timeout
		set_collision_mask_value(2, true)

	else:
		pass # Ground slam!

func is_on_ladder() -> bool:
	for area in hurtbox_component.get_overlapping_areas():
		if area.is_in_group("ladders"):
			var shape = area.get_node_or_null("CollisionShape2D")
			global_position.x = shape.global_position.x
			return true
	return false

func _update_respawn_point(position:Vector2) -> void:
	last_safe_position = position
	print(position)

func _on_death() -> void:
	fsm.change_state("Death")

func _on_hit_hazard(entity:Node2D, damage:float) -> void:
	if entity != self:
		return

	# Check health first otherwise the scene changes AFTER respawning player!
	if health_component.current_health <= 0:
		fsm.change_state("Death")
	else:
		fsm.change_state("HitHazard")
	
func _gain_energy(entity:Node2D) -> void:
	if entity.is_in_group("energy_gaining"):
		energy_component.gain_energy(4)
	
func x_input(_delta: float) -> void:
	print(fsm.current_state.name)
	if InputManager.input_lock:
		# Keep the player moving on room transition when input locked
		velocity.x = sign(velocity.x) * move_component.speed
		return
		
	# If not input locked, set zdirection as per the relevant input
	move_component.direction = Input.get_axis("move_left", "move_right")

# Testing inputs - not to be shipped !!!!
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.input_lock:
		return
	fsm.handle_input(event)

	if Input.is_action_just_pressed("shoot"):
		pass
		#SignalBus.camera_zoom_requested.emit(1.2, 0.25)
		#SignalBus.screenshake_requested.emit(10.0, 10.0, 0.5)
		#SignalBus.zone_banner_requested.emit("Big Bad Boss", true)
		#AudioManager.start_music("res://states/world_state/music/temple_theme.ogg", 1.0)
		#AudioManager.stop_music()
		
		#energy_component.consume_energy(4)
		#hurtbox_component.receive_damage(3, Vector2(), 100)
		#print(health_component.current_health)
		#pass

	
