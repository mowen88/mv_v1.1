class_name HitEffect
extends GPUParticles2D

static func spawn(parent:Node, pos:Vector2) -> void:
	const SCENE = preload("res://states/world_state/particles/hit_effect/hit_effect.tscn")
	var fx = SCENE.instantiate() as HitEffect
	parent.add_child(fx)
	fx.global_position = pos
	fx.emitting = true

func ready() -> void:
	emitting = true
	await finished
	queue_free()
