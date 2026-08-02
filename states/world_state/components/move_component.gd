class_name MoveComponent
extends Node

# Configurable movement metrics per entity
@export var gravity: float = 800.0
@export var speed: float = 75.0
@export var acceleration: float = 700.0
@export var deceleration: float = 900.0
@export var jump_velocity: float = -280.0
@export var max_fall_speed: float = 800.0

# Add parent reference
var actor: CharacterBody2D

# Assign variables
@onready var direction: float = 0.0

var facing: int = 1:
	set(value):
		facing = value
		actor.animated_sprite.flip_h = (facing == -1)

func _ready() -> void:
	actor = get_parent()
	
	actor.floor_max_angle = deg_to_rad(40.0)

func process_movement(delta: float) -> void:

	if direction != 0:
		self.facing = int(sign(direction))
		
		# Smoothly accelerate toward maximum run speed
		actor.velocity.x = move_toward(actor.velocity.x, direction * speed, acceleration * delta)
	else:
		# Smoothly decelerate to a stop instead of instantly cutting to 0
		actor.velocity.x = move_toward(actor.velocity.x, 0, deceleration * delta)
