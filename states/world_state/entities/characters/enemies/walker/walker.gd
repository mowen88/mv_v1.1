class_name Walker
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent

@onready var knockback_resistance: float = 2.0

var last_attacker_pos: Vector2

func _ready() -> void:
	health_component.died.connect(_on_died)
	print(health_component.current_health)
	hurtbox_component.hit_received.connect(_on_hurtbox_received_damage)

func _on_hurtbox_received_damage(attacker_pos:Vector2, knockback_force:float):
	last_attacker_pos = attacker_pos
	fsm.change_state("WalkerHit")
	flash_component.play_flash()
	apply_knockback(attacker_pos, knockback_force)

func apply_knockback(attacker_pos:Vector2, knockback_force:float) -> void:
	var dir = sign(global_position.x - attacker_pos.x)
	var final_force = knockback_force/knockback_resistance
	velocity.x = dir * final_force
	velocity.y = -100

#Testing with input - to be deleted for shipping !!!!
func _unhandled_input(event: InputEvent) -> void:

	# Test input
	if event.is_action_pressed("shoot"):
		#health_component.damage(1)
		#print(health_component.current_health)
		pass
	
func _on_died() -> void:
	set_collision_mask_value(2, false)
	set_collision_mask_value(1, true)
	fsm.change_state("WalkerDeath")
	
