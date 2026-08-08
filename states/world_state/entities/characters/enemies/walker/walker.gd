class_name Walker
extends CharacterBody2D



@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var move_component: MoveComponent = $MoveComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var flash_component: FlashComponent = $FlashComponent
@onready var squash_stretch_component: SquashStretchComponent = $SquashStretchComponent


func _ready() -> void:
	health_component.died.connect(_on_death)

func _on_death() -> void:
	set_collision_mask_value(2, false)
	hitbox_component.monitoring = false
	hurtbox_component.monitorable = false
	
	fsm.change_state("Death")

#Testing with input - to be deleted for shipping !!!!
func _unhandled_input(event: InputEvent) -> void:

	# Test input
	if event.is_action_pressed("shoot"):
		#health_component.damage(1)
		#print(health_component.current_health)
		pass
	
	
