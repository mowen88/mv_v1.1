extends Node2D

@export var collapse_delay: float = 0.5   # Time to disappear
@export var reappear_time: float = 3.0    # Time to return

@onready var timer: Timer = $Timer

# Arrays to hold the platforms
var platforms: Array = []
var collision_shapes: Array = []
var areas: Array = []
var sprites: Array = []

var triggered: bool = false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	
	for child in get_children():
		if child is StaticBody2D:
			platforms.append(child)
			collision_shapes.append(child.get_node("CollisionShape2D"))
			
			var area = child.get_node("Area2D")
			areas.append(area)
			
			var sprite = child.get_node("AnimatedSprite2D")
			sprites.append(sprite)
			
			sprite.animation_finished.connect(_on_sprite_animation_finished.bind(sprite))
			
	for area in areas:
		area.body_entered.connect(_trigger_group)

func _trigger_group(body: Node2D) -> void:
	if triggered:
		return
		
	triggered = true
	timer.wait_time = collapse_delay
	timer.one_shot = true
	timer.start()
	
	for sprite in sprites:
		sprite.play("shaking")

func _on_timer_timeout() -> void:
	if triggered and collision_shapes[0].disabled == false:
		# STEP 1: Collapse all of them together
		for i in range(platforms.size()):
			collision_shapes[i].set_deferred("disabled", true)
			areas[i].set_deferred("monitoring", true) # Keep monitoring on so we can check overlaps!
			sprites[i].play("breaking")
			
		timer.wait_time = reappear_time
		timer.start()
	else:
		# Check if player is blocking ANY platform in the group
		var player_is_blocking = false
		
		for area in areas:
			var overlapping_bodies = area.get_overlapping_bodies()
			for body in overlapping_bodies:
				if body.is_in_group("player"):
					player_is_blocking = true
					break
			if player_is_blocking:
				break
				
		if player_is_blocking:
			# Check if body still in the way on time interval
			timer.wait_time = 0.2
			timer.start()
		else:
			# If bodies out the way then respawn all platforms
			for i in range(platforms.size()):
				collision_shapes[i].set_deferred("disabled", false)
				sprites[i].visible = true
				sprites[i].play("returning")
				
			triggered = false # Reset so they can be triggered again

func _on_sprite_animation_finished(sprite: AnimatedSprite2D) -> void:
	if sprite.animation == "breaking":
		sprite.visible = false
