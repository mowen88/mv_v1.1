class_name Player
extends CharacterBody2D

const ATTACK_DECELERATION: float = 300.0
const MAX_JUMPS: int = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent

@onready var sword = $SwordScene

var jump_counter: int = 0

func x_input(_delta: float) -> void:
	if InputManager.input_lock:
		# Keep the player moving on room transition when input locked
		velocity.x = sign(velocity.x) * move_component.speed
		return
		
	# If not input locked, set direction as per the relevant input
	move_component.direction = Input.get_axis("move_left", "move_right")

# Testing inputs - not to be shipped !!!!
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.input_lock:
		return
	fsm.handle_input(event)

	if event.is_action_pressed("shoot"):
		health_component.damage(1)
		print(health_component.current_health)
		pass

	
