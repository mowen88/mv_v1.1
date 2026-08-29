class_name Player
extends CharacterBody2D

@onready var death_particles: GPUParticles2D = $DeathParticle
@onready var heal_particles: GPUParticles2D = $HealParticle

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var energy_component: EnergyComponent = $EnergyComponent

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent
@onready var squash_stretch_component: SquashStretchComponent = $SquashStretchComponent

@onready var sword = $SwordScene
@onready var beam = $BeamScene

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer

var last_safe_position: Vector2 = Vector2.ZERO
var jump_counter: int = 0
var air_attack_count: int = 0

# Temporary save data
var current_coins: int = 0
var banked_coins: int = 0
var session_visited_rooms: Array = []
		
func _ready() -> void:	
	
	_get_initial_coins()
	_get_initial_energy()
	
	hurtbox_component.hit_received.connect(_on_hit)
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
	
	# Get swipe signal
	SignalBus.swipe_down_detected.connect(_on_swipe_down)

func drop_through_platform() -> void:

	if is_on_wall():
		velocity.x = 25 * -move_component.facing
	# Disable the platform collisions, wait short time and reenable
	set_collision_mask_value(7, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(7, true)

# Mobile touchscreen only!
func _on_swipe_down() -> void:
	if InputManager.input_lock:
		return
	
	var valid_states = ["Idle", "Run"]
	if fsm.current_state.name in valid_states and is_on_floor():
		# Stop player sticking to wall in run state fix by bouncing away slightly
		drop_through_platform()
	else:
		pass # Ground slam!

func _get_initial_coins() -> void:
	if SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		banked_coins = SaveManager.SAVE_DATA[SaveManager.current_slot].get("coins", 0)
	else:
		banked_coins = 0
	current_coins = 0 # Fresh run starts with 0 unbanked coins
	# Signal to update UI
	SignalBus.player_coins_changed.emit(banked_coins)
	
func _get_initial_energy() -> void:
	if SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		var saved_energy = SaveManager.SAVE_DATA[SaveManager.current_slot].get("energy", 0)
		energy_component.current_energy = saved_energy
	else:
		energy_component.current_energy = 0
			
func is_on_ladder() -> bool:
	for area in hurtbox_component.get_overlapping_areas():
		if area.is_in_group("ladders"):
			var shape = area.get_node_or_null("CollisionShape2D")
			global_position.x = shape.global_position.x
			return true
	return false

func _update_respawn_point(respawn_position:Vector2) -> void:
	last_safe_position = respawn_position

func _on_hit(hitbox: Area2D, _knockback_force:float):
	if health_component.current_health <= 0:
		return
		
	var hazard = true if hitbox.owner.is_in_group("hazards") else false

	if hazard:
		fsm.change_state("HitHazard")
	else:
		fsm.change_state("Hit")

func collect_coin(amount: int) -> void:
	current_coins += amount
	# Signal to update UI
	SignalBus.player_coins_changed.emit(banked_coins + current_coins)

func _on_death() -> void:
	# Start the death fade screen
	death_particles.emitting = true
	death_particles.z_index = 10
	animated_sprite.z_index = 11
	fsm.change_state("Death")
	current_coins = 0
	
func _gain_energy(entity:Node2D) -> void:
	if entity.is_in_group("energy_gaining"):
		energy_component.gain_energy(3)
	
func x_input(_delta: float) -> void:
	if InputManager.cutscene_lock or InputManager.input_lock:
		return
		
	# If not input locked, set zdirection as per the relevant input
	move_component.direction = Input.get_axis("move_left", "move_right")

# Testing inputs - not to be shipped !!!!
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.cutscene_lock or InputManager.input_lock:
		return
		
	fsm.handle_input(event)
	print(fsm.current_state.name)

	if event.is_action_pressed("shoot"):
		SaveManager.add_ability("Glide")
		SaveManager.add_ability("Jump Attack")
		SaveManager.add_ability("Ground Slam")
		print(SaveManager.SAVE_DATA[SaveManager.current_slot])
#
		#SignalBus.trap_doors_unlocked.emit("trap_room_test_01")
		#SignalBus.camera_zoom_requested.emit(1.2, 0.25)
		#SignalBus.screenshake_requested.emit(10.0, 10.0, 0.5)
		#
		## Testing cycle through states to test: inactive -> in_progress -> completed
		#if QuestManager.get_quest_state("find_the_key") == "Inactive":
			#QuestManager.set_quest_state("find_the_key", "In progress")
			#print("Quest State Changed: IN_PROGRESS")
		#elif QuestManager.get_quest_state("find_the_key") == "In progress":
			#QuestManager.set_quest_state("find_the_key", "Completed")
			#print("Quest State Changed: COMPLETED")
		#return
		#
		#SignalBus.zone_banner_requested.emit("Big Bad Boss", true)
		#AudioManager.start_music("res://states/world_state/music/temple_theme.ogg", 1.0)
		#AudioManager.stop_music()
		
		#energy_component.consume_energy(4)
		#hurtbox_component.receive_damage(3, Vector2(), 100)
		#print(health_component.current_health)
		#pass

	
