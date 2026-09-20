extends StaticBody2D

@export var is_open: bool = false
@export var keys_required: int = 1

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_sprite: AnimatedSprite2D = $DoorSprite
@onready var interaction_area: Area2D = $Area2D
@onready var persistence_component = $PersistenceComponent

func _ready() -> void:
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	# If the door is already open from saved data, open it immediately without animations
	if is_open:
		collision_shape.disabled = true
		interaction_area.monitoring = false
		# Optionally set door sprites to their fully open frame/state here if needed
	else:
		interaction_area.body_entered.connect(_on_body_entered)

	# Count how many lock sprites are nested under DoorSprite
	var lock_nodes = door_sprite.find_children("*", "AnimatedSprite2D", false, false)
	var locks = []
	for node in lock_nodes:
		locks.append(node)

func _on_persistent_state_loaded(previous_position: Vector2) -> void:
	
	global_position = previous_position
	
	# Disable collisions
	collision_shape.disabled = true
	
	# Set the door to its last frame
	var max_frame = door_sprite.sprite_frames.get_frame_count("default") - 1
	door_sprite.frame = max_frame
	
	# Kill the lock sprites
	var children = door_sprite.get_children()
	for child in children:
		child.queue_free()
	
func _on_body_entered(body: Node) -> void:
	if is_open:
		return

	# Check if the colliding body is the player
	if body.is_in_group("player"):
		check_player_keys()

func check_player_keys() -> void:
	# 1. Safely grab save data and items dictionary
	var current_slot = SaveManager.current_slot
	if not SaveManager.SAVE_DATA.has(current_slot):
		SignalBus.tutorial_message_requested.emit("You need %d keys for this door." % keys_required)
		return
		
	var slot_data = SaveManager.SAVE_DATA[current_slot]
	if not slot_data.has("items"):
		SignalBus.tutorial_message_requested.emit("You need %d keys for this door." % keys_required)
		return
		
	var player_items: Dictionary = slot_data["items"]
	var player_key_count = int(player_items.get("Key", 0))
	
	# 2. Check if player has enough keys
	if player_key_count >= keys_required:
		open_door()
	else:
		SignalBus.tutorial_message_requested.emit("You need %d keys for this door." % keys_required)

func open_door() -> void:
	is_open = true
	interaction_area.monitoring = false
	
	var children = door_sprite.get_children()

	for child in children:
		child.play() # Ensure this animation has looping turned OFF in SpriteFrames!
		child.animation_finished.connect(func():_start_door_opening_animation(), CONNECT_ONE_SHOT)
		
func _start_door_opening_animation() -> void:
	door_sprite.play()
	
	door_sprite.animation_finished.connect(func():
		collision_shape.disabled = true
		persistence_component.add_to_peristent_list()
	, CONNECT_ONE_SHOT)
