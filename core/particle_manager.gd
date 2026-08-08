extends Node

var particle_scenes = {
	"money_burst": preload("res://states/world_state/particles/money_burst/money_burst_particle.tscn"),
	"bush_leaves": preload("res://states/world_state/particles/bush_leaves/bush_leaves_particle.tscn"),
	"hit_effect": preload("res://states/world_state/particles/hit_effect/hit_effect.tscn"),
	"small_blast": preload("res://states/world_state/particles/small_blast/small_blast.tscn"),
}
var pools: Dictionary = {}
const POOL_SIZE_PER_EFFECT: int = 15

func _ready() -> void:
	initialize_pools()

func initialize_pools() -> void:
	for effect_name in particle_scenes:
		var scene = particle_scenes[effect_name]
		_create_pool_for_scene(effect_name, scene)

# Helper function now indexes by string name directly
func _create_pool_for_scene(effect_name: String, scene: PackedScene) -> Array:
	var pool: Array = []
	
	for i in range(POOL_SIZE_PER_EFFECT):
		var fx = scene.instantiate() as Node2D
		fx.visible = false
		add_child(fx)
		
		if fx is GPUParticles2D:
			fx.emitting = true
			
		pool.append(fx)
		
	pools[effect_name] = pool
	
	# Wait a frame to let GPU particles initialize properly without freezing
	await get_tree().process_frame
	for fx in pool:
		if is_instance_valid(fx):
			if fx is GPUParticles2D:
				fx.emitting = false
			fx.visible = false
			
	return pool

func play(effect_name: String, pos: Vector2, duration: float = 0.0) -> void:
	if not particle_scenes.has(effect_name):
		return
		
	# Ensure the pool exists
	if not pools.has(effect_name):
		await _create_pool_for_scene(effect_name, particle_scenes[effect_name])
		
	var pool: Array = pools[effect_name]
	var fx: Node2D = null
	
	# Find an inactive node in the pool
	for instance in pool:
		if is_instance_valid(instance) and not instance.visible:
			fx = instance
			break
			
	# Dynamic fallback if pool is exhausted
	if not fx:
		var scene = particle_scenes[effect_name]
		fx = scene.instantiate() as Node2D
		add_child(fx)
		pool.append(fx)
		
	fx.global_position = pos
	fx.visible = true
	
	# Handle GPUParticles2D
	if fx is GPUParticles2D:
		if duration <= 0.0:
			fx.one_shot = true
			fx.restart()
			fx.emitting = true
			_monitor_gpu_particle(fx, 0.0)
		else:
			fx.one_shot = false
			fx.restart()
			fx.emitting = true
			_monitor_gpu_particle(fx, duration)
			
	# Handle AnimatedSprite2D (either root node or child node)
	else:
		var anim_sprite: AnimatedSprite2D = fx if fx is AnimatedSprite2D else fx.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.play()
			if not anim_sprite.animation_finished.is_connected(_on_sprite_finished.bind(fx, anim_sprite)):
				anim_sprite.animation_finished.connect(_on_sprite_finished.bind(fx, anim_sprite), CONNECT_ONE_SHOT)

func _on_sprite_finished(fx: Node2D, anim_sprite: AnimatedSprite2D) -> void:
	if is_instance_valid(anim_sprite):
		anim_sprite.stop()
	if is_instance_valid(fx):
		fx.visible = false
		
func _monitor_gpu_particle(fx: GPUParticles2D, duration: float) -> void:
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		if is_instance_valid(fx):
			fx.emitting = false
			
	if is_instance_valid(fx):
		await fx.finished
	
	if is_instance_valid(fx):
		fx.emitting = false
		fx.visible = false
