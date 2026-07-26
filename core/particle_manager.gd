extends Node

var particle_scenes = {
	"hit_effect": preload("res://states/world_state/particles/hit_effect/hit_effect.tscn")
}

var pools: Dictionary = {}
const POOL_SIZE_PER_EFFECT: int = 15

func _ready() -> void:
	initialize_pools()

func initialize_pools() -> void:
	for key in particle_scenes:
		pools[key] = []
		var scene = particle_scenes[key]
		
		for i in range(POOL_SIZE_PER_EFFECT):
			var fx = scene.instantiate() as Node2D
			fx.visible = false
			add_child(fx)
			
			# Force shader warm-up on creation
			if fx is GPUParticles2D:
				fx.emitting = true
				
			pools[key].append(fx)
			
	# Wait one frame for shaders to compile, then reset them into an inactive state
	await get_tree().process_frame
	for key in pools:
		for fx in pools[key]:
			if fx is GPUParticles2D:
				fx.emitting = false
			fx.visible = false

func play(effect_name: String, pos: Vector2) -> void:
	if not particle_scenes.has(effect_name):
		push_warning("Particle effect not found in manager: " + effect_name)
		return
		
	var pool: Array = pools[effect_name]
	var fx: Node2D = null
	
	# Find an available inactive particle in the pool
	for instance in pool:
		if not instance.visible:
			fx = instance
			break
			
	# Fallback if pool is exhausted
	if not fx:
		fx = particle_scenes[effect_name].instantiate() as Node2D
		add_child(fx)
		pool.append(fx)
		
	fx.global_position = pos
	fx.visible = true
	
	# Handle GPUParticles2D
	if fx is GPUParticles2D:
		fx.restart()
		fx.emitting = true
		_monitor_gpu_particle(fx)
		

func _monitor_gpu_particle(fx: GPUParticles2D) -> void:
	# Wait for the finished signal entirely from the manager
	await fx.finished
	fx.emitting = false
	fx.visible = false

func _on_anim_finished(fx: Node2D, anim_sprite: AnimatedSprite2D) -> void:
	anim_sprite.stop()
	fx.visible = false
