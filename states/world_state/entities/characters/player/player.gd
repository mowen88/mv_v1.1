class_name Player
extends CharacterBody2D

const MAX_JUMPS: int = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var energy_component: EnergyComponent = $EnergyComponent

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent

@onready var sword = $SwordScene

var jump_counter: int = 0

		
func _ready() -> void:	
	health_component.died.connect(_on_died)
	
	health_component.health_changed.connect(func(val):SignalBus.player_health_changed.emit(val))
	health_component.max_health_changed.connect(func(val):SignalBus.player_max_health_changed.emit(val))
	
	energy_component.energy_changed.connect(func(val): SignalBus.player_energy_changed.emit(val))
	energy_component.max_energy_changed.connect(func(val): SignalBus.player_max_energy_changed.emit(val))
	
	SignalBus.player_max_health_changed.emit(health_component.max_health)
	SignalBus.player_health_changed.emit(health_component.current_health)

	SignalBus.player_max_energy_changed.emit(energy_component.max_energy)
	SignalBus.player_energy_changed.emit(energy_component.current_energy)
	
	SignalBus.player_energy_gained.connect(_gain_energy)
	
func _gain_energy(entity:Node2D) -> void:
	if entity.is_in_group("energy_gaining"):
		energy_component.gain_energy(4)
	
func x_input(_delta: float) -> void:
	if InputManager.input_lock:
		# Keep the player moving on room transition when input locked
		velocity.x = sign(velocity.x) * move_component.speed
		return
		
	# If not input locked, set zdirection as per the relevant input
	move_component.direction = Input.get_axis("move_left", "move_right")

func _on_died() -> void:
	fsm.change_state("death")

# Testing inputs - not to be shipped !!!!
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.input_lock:
		return
	fsm.handle_input(event)

	if event.is_action_pressed("shoot"):
		SignalBus.screenshake_requested.emit(15.0, 15.0, 0.5)
		SignalBus.zone_banner_requested.emit("Big Bad Boss", true)
		AudioManager.start_music("res://states/world_state/music/temple_theme.ogg", 1.0)
		AudioManager.stop_music()
		
		#energy_component.consume_energy(4)
		#hurtbox_component.receive_damage(3, Vector2(), 100)
		#print(health_component.current_health)
		#pass

	
