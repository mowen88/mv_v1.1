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
@onready var hitbox_component: HitboxComponent = $HitboxComponent

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
	
func _gain_energy(entity: Node2D, knockback_force: float) -> void:
	if entity.is_in_group("energy_gaining"):
		energy_component.gain_energy(knockback_force / 50)
	
func x_input(_delta: float) -> void:
	if InputManager.input_lock:
		# Keep the player moving on room transition when input locked
		velocity.x = sign(velocity.x) * move_component.speed
		return
		
	# If not input locked, set direction as per the relevant input
	move_component.direction = Input.get_axis("move_left", "move_right")

func _on_died() -> void:
	SignalBus.player_died.emit()

# Testing inputs - not to be shipped !!!!
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.input_lock:
		return
	fsm.handle_input(event)

	if event.is_action_pressed("shoot"):
		health_component.damage(1)
		print(health_component.current_health)
		pass

	
