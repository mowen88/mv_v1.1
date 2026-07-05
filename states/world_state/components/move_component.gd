class_name MoveComponent
extends Node

# Configurable movement metrics per entity
@export var gravity: float = 900.0
@export var speed: float = 75.0
@export var acceleration: float = 700.0
@export var deceleration: float = 900.0
@export var jump_velocity: float = -280.0

# Add parent reference
var actor: CharacterBody2D

# Assign variables
@onready var direction: float = 0.0

var facing: int = 1:
	set(value):
		facing = value
		actor.animated_sprite.flip_h = (facing == -1)

func _ready() -> void:
	if get_parent() is CharacterBody2D:
		actor = get_parent()

func process_movement(delta: float) -> void:

	if direction != 0:
		self.facing = int(sign(direction))
		
		## Cut velocity to 0 for snappy turnarounds? Highlighted out for now...
		#if (direction > 0 and actor.velocity.x < 0) or (direction < 0 and actor.velocity.x > 0):
			#actor.velocity.x = 0.0 # Instantly cut the sliding momentum to zero

		# Smoothly accelerate toward maximum run speed
		actor.velocity.x = move_toward(actor.velocity.x, direction * speed, acceleration * delta)
	else:
		# Smoothly decelerate to a stop instead of instantly cutting to 0
		actor.velocity.x = move_toward(actor.velocity.x, 0, deceleration * delta)
