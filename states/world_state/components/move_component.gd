class_name MoveComponent
extends Node

# Configurable movement metrics per entity
@export var gravity: float = 800.0
@export var speed: float = 75.0
@export var acceleration: float = 700.0
@export var deceleration: float = 900.0
@export var jump_velocity: float = -280.0
@export var max_fall_speed: float = 800.0
@export var slide_speed: float = 100.00

# Add parent reference
var actor: CharacterBody2D

# Assign variables
@onready var direction: float = 0.0

var facing: int = 1:
	set(value):
		facing = value
		owner.animated_sprite.flip_h = (facing == -1)

func _ready() -> void:
	owner.floor_max_angle = deg_to_rad(40.0)

# In move component as it will be same for all characters
func is_on_slope() -> bool:
	if owner.get_slide_collision_count() > 0:
		var collision = owner.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			
			if collider and collider.is_in_group("slopes"):
				var normal = collision.get_normal()
				
				# Calculate the downward slide vector down slope
				var slide_dir = Vector2.DOWN.slide(normal).normalized()
				# Update velocity multiplied by export variable slide speed
				owner.velocity = slide_dir * slide_speed
				# Slight impulse to snap player to slope
				owner.velocity.y += 20
				# Force the facing direction
				facing = int(sign(owner.velocity.x))
				return true
				
	return false

func process_movement(delta: float) -> void:

	if direction != 0:
		self.facing = int(sign(direction))
		
		# Smoothly accelerate toward maximum run speed
		owner.velocity.x = move_toward(owner.velocity.x, direction * speed, acceleration * delta)
	else:
		# Smoothly decelerate to a stop instead of instantly cutting to 0
		owner.velocity.x = move_toward(owner.velocity.x, 0, deceleration * delta)
