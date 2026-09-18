extends Node2D

@export var collect_particle: String

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_component = $InteractionComponent
@onready var persistence_component = $PersistenceComponent

@export var float_amplitude: float = 4.0 
@export var float_speed: float = 3.0       
@export var rotation_speed: float = 0.5   

var initial_y: float

func _ready() -> void:
	interaction_component.interact.connect(_on_interacted)
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	initial_y = global_position.y

func _process(delta: float) -> void:
	
	_apply_motion(delta)

func _apply_motion(_delta: float) -> void:
	# Sine wave for smooth vertical bob
	var time = Time.get_ticks_msec() / 1000.0
	position.y = initial_y + sin(time * float_speed) * float_amplitude
	animated_sprite.rotation = cos(time * float_speed * 0.8) * 0.15

func _on_interacted(_player:CharacterBody2D) -> void:
	persistence_component.add_to_peristent_list()
	SaveManager.add_item("Key")
	ParticleManager.play(collect_particle, global_position)
	queue_free()
	SignalBus.tutorial_message_requested.emit("Key collected")

func _on_persistent_state_loaded(_pos: Vector2) -> void:
	queue_free()
