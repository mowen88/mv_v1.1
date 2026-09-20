extends StaticBody2D

@export var is_open: bool = false
@export var keys_required: int = 1

@export var rejected_sound = AudioStream
@export var lock_open_sound = AudioStream
@export var door_open_sound = AudioStream

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_sprite: AnimatedSprite2D = $DoorSprite
@onready var interaction_component = $DoorSprite/LockSprite/InteractionComponent
@onready var persistence_component = $PersistenceComponent

var rejected_sound_allowed: bool = true
func _ready() -> void:
	interaction_component.interact.connect(_on_interacted)
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	# If the door is already open from saved data, open it immediately without animations
	if is_open:
		collision_shape.disabled = true

	# Count how many lock sprites are nested under DoorSprite
	var lock_nodes = door_sprite.find_children("*", "AnimatedSprite2D", false, false)
	var locks = []
	for node in lock_nodes:
		locks.append(node)

func _on_interacted(_player: CharacterBody2D) -> void:
	check_player_keys()
	if rejected_sound_allowed:
		AudioManager.play_sfx(rejected_sound)

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

func check_player_keys() -> void:
	
	# Determine message based on plural or not
	var message: String
	if keys_required > 1:
		"%d keys required to open the door" % keys_required
	else:
		message = "1 key required to open the door" 

	# 1. Safely grab save data and items dictionary
	var current_slot = SaveManager.current_slot
	if not SaveManager.SAVE_DATA.has(current_slot):
		SignalBus.tutorial_message_requested.emit(message)
		return
		
	var slot_data = SaveManager.SAVE_DATA[current_slot]
	if not slot_data.has("items"):
		SignalBus.tutorial_message_requested.emit(message)
		return
		
	var player_items: Dictionary = slot_data["items"]
	var player_key_count = int(player_items.get("Key", 0))
	
	# 2. Check if player has enough keys
	if player_key_count >= keys_required:
		rejected_sound_allowed = false
		open_door()
	else:
		SignalBus.tutorial_message_requested.emit(message)

func open_door() -> void:
	is_open = true
	AudioManager.play_sfx(lock_open_sound)
	
	var children = door_sprite.get_children()

	for child in children:
		child.play() # Ensure this animation has looping turned OFF in SpriteFrames!
		child.animation_finished.connect(func():_start_door_opening_animation(), CONNECT_ONE_SHOT)
		
func _start_door_opening_animation() -> void:
	door_sprite.play()
	AudioManager.play_sfx(door_open_sound)
	
	door_sprite.animation_finished.connect(func():
		collision_shape.disabled = true
		persistence_component.add_to_peristent_list()
	, CONNECT_ONE_SHOT)
