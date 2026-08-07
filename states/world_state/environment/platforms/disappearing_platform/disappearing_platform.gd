extends StaticBody2D

@export var collapse_delay: float = 0.5   # Time to disappear
@export var reappear_time: float = 3.0    # Time to return

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var triggered: bool = false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	area.body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	triggered = true
	timer.wait_time = collapse_delay
	timer.one_shot = true
	timer.start()
	
	sprite.play("shaking")

func _on_timer_timeout() -> void:
	if triggered and collision_shape.disabled == false:
		# Collapse logic...
		collision_shape.set_deferred("disabled", true)
		area.set_deferred("monitoring", true) # Keep monitoring on so we can check overlaps!
		sprite.play("breaking")
		timer.wait_time = reappear_time
		timer.start()
	else:
		# Get bodies inside trigger area
		var overlapping_bodies = area.get_overlapping_bodies()
		
		# Filter out things that shouldn't block it
		var player_is_blocking = false
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				player_is_blocking = true
				break
				
		if player_is_blocking:
			# Check if body still in the way on time interval
			timer.wait_time = 0.2
			timer.start()
		else:
			# If bodies out the way then respawn platform
			collision_shape.set_deferred("disabled", false)
			sprite.visible = true
			sprite.play("returning")
			triggered = false

func _on_animation_finished() -> void:
	if sprite.animation == "breaking":
		sprite.visible = false
