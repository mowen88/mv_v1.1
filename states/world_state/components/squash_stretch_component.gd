class_name SquashStretchComponent
extends Node

@export var sprite: AnimatedSprite2D
@export var hurtbox_component: HurtboxComponent

var tween: Tween

func _ready() -> void:
	if hurtbox_component:
		hurtbox_component.hit_received.connect(on_hit_received)

func on_hit_received(_hitbox: Area2D, _knockback: float) -> void:
	owner.squash_stretch_component.squash_stretch(Vector2(1.3, 0.7), Vector2(0.8, 1.2), 0.15)

func squash_stretch(squash_scale: Vector2, stretch_scale: Vector2, duration: float) -> void:
	if not sprite:
		return
		
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween().set_parallel(false)
	
	# Phase 1: Squash instantly on impact
	tween.tween_property(sprite, "scale", squash_scale, duration * 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Phase 2: Overshoot into stretch
	tween.tween_property(sprite, "scale", stretch_scale, duration * 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Phase 3: Spring back smoothly to normal scale (Vector2.ONE)
	tween.tween_property(sprite, "scale", Vector2.ONE, duration * 0.6)\
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
