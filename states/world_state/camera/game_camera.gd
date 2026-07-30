extends Camera2D

var shake_tween: Tween

@export var x_offset_distance: float = 8.0
@export var lerp_speed: float = 8.0

var x_offset: float = 0.0
var y_offset: float = 0.0

var current_pos: Vector2 = Vector2.ZERO

var is_overridden: bool = false
var locked_position: Vector2 = Vector2.ZERO
var followed_target: Node2D = null
var lock_x: bool = true
var lock_y: bool = true

func _ready() -> void:
	# Connect to the global signal bus
	SignalBus.screenshake_requested.connect(shake)
	SignalBus.camera_override_requested.connect(set_override)
	SignalBus.camera_override_cleared.connect(clear_override)

func update_target(player:CharacterBody2D, delta:float) -> void:
	
	var target_pos = player.global_position
	var target_x_offset = player.move_component.facing * x_offset_distance

	x_offset = lerp(x_offset, target_x_offset, lerp_speed * delta)
	target_pos.x += x_offset
	
	#if player.global_position.y > global_position.y:
		#global_position.y = player.global_position.y

	if is_overridden:
		 # Follow if the target is a node2D or inherits from Node2D like another character
		if followed_target and is_instance_valid(followed_target):
			locked_position = followed_target.global_position
		
		# Handle the camera trigger colliders x and y lock export variables
		if lock_x:
			target_pos.x = locked_position.x
		if lock_y:
			target_pos.y = locked_position.y

			
	# Update camera pos
	current_pos = target_pos
	print(lerp_speed)

func set_override(pos:Vector2, x:bool = true, y:bool = true, follow:Node2D = null) -> void:
	locked_position = pos
	followed_target = follow
	lock_x = x
	lock_y = y
	is_overridden = true

func clear_override() -> void:
	is_overridden = false
	followed_target = null

func _process(delta: float) -> void:
	global_position = global_position.lerp(current_pos, lerp_speed * delta)

## Triggers a screenshake using max X and Y pixel boundaries over a set duration
func shake(max_x: float, max_y: float, duration: float) -> void:
	if not SaveManager.SETTINGS_DATA.get("Screenshake", true):
		return
		
	if shake_tween:
		shake_tween.kill()
		
	shake_tween = create_tween()
	
	# Determine how fast the camera shakes
	var shake_speed: float = 0.05 
	var loops: int = int(duration / shake_speed)
	
	for i in range(loops):
		# Calculate decay
		var t: float = float(i) / float(loops)
		var current_decay: float = 1.0 - t
		
		# Generate a random target offset within our boundary limits
		var target_offset = Vector2(
			randf_range(-max_x, max_x) * current_decay,
			randf_range(-max_y, max_y) * current_decay
		)
		
		# Snap back or move rapidly to the new offset position
		shake_tween.tween_property(self, "offset", target_offset, shake_speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
			
	# Final step: Always guarantee the camera perfectly centers itself back
	shake_tween.tween_property(self, "offset", Vector2.ZERO, shake_speed)
