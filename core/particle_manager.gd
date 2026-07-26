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

func play(scene: PackedScene, pos: Vector2) -> void:
	if not scene:
		return
		
	var scene_path = scene.resource_path
	
	if not pools.has(scene_path):
		pools[scene_path] = []
		for i in range(POOL_SIZE_PER_EFFECT):
			var fx = scene.instantiate() as Node2D
			fx.visible = false
			add_child(fx)
			if fx is GPUParticles2D:
				fx.emitting = true
			pools[scene_path].append(fx)
			
		await get_tree().process_frame
		for fx in pools[scene_path]:
			if fx is GPUParticles2D:
				fx.emitting = false
			fx.visible = false
		
	var pool: Array = pools[scene_path]
	var fx: Node2D = null
	
	for instance in pool:
		if not instance.visible:
			fx = instance
			break
			
	if not fx:
		fx = scene.instantiate() as Node2D
		add_child(fx)
		pool.append(fx)
		
	fx.global_position = pos
	fx.visible = true
	
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
