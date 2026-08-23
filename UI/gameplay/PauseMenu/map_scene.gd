extends Control

@onready var room_container: Node2D = $SubViewportContainer/SubViewport/RoomContainer

# Zoom configuration
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.1

@export var max_drag_range_x: float = 800.0
@export var max_drag_range_y: float = 400.0

# Touch/Drag tracking variables
var dragging: bool = false
var last_pinch_distance: float = 0.0
var touch_points: Dictionary = {}

@onready var player_icon: Sprite2D = $SubViewportContainer/SubViewport/RoomContainer/PlayerIcon
@onready var recentre_button: Button = $RecentreButton

# Cache references so the re-center button can reuse them
var cached_current_room: Node2D = null
var cached_player_node: Node2D = null

func _ready() -> void:
	recentre_button.pressed.connect(_on_recentre_pressed)

func _on_recentre_pressed() -> void:
	# Reset zoom and position
	room_container.scale = Vector2(1.0, 1.0)
	update_map_display(cached_current_room, cached_player_node)
	
func update_map_display(current_room: Node2D = null, player_node: Node2D = null) -> void:
	cached_current_room = current_room
	cached_player_node = player_node
	
	var visited_rooms = []
	if SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		visited_rooms = SaveManager.SAVE_DATA[SaveManager.current_slot].get("visited_rooms", [])

	var active_room_name = current_room.name.to_lower() if current_room else ""
	var target_map_node: Sprite2D = null

	for room_node in room_container.get_children():
		if room_node is Sprite2D and room_node.name != "PlayerIcon":
			var room_id = room_node.name.to_lower()
			
			var is_visited = false
			for visited in visited_rooms:
				if visited.to_lower() == room_id or room_id in visited.to_lower():
					is_visited = true
					break
			
			room_node.visible = is_visited
			
			# Identify the map sprite matching our current room
			if room_id == active_room_name:
				target_map_node = room_node

	# Position and center on the current room / player
	if target_map_node and player_node and current_room:
		_center_on_room_and_player(target_map_node, player_node, current_room)

func _center_on_room_and_player(map_sprite: Sprite2D, player_node: Node2D, room_node: Node2D) -> void:
	# 1. Player's local position from the center of the room
	var player_local = player_node.global_position - room_node.global_position
	
	# 2. Your standard single-room world dimensions
	var standard_room_world_size = Vector2(260.0, 120.0)
	
	# 3. Find standard 1 high, 1 wide room size for multiplier
	var standard_map_room_size = Vector2(117.0, 54.0)
	
	# Get ratio multiplier to map game space to UI space on the map
	var scale_ratio = standard_map_room_size / standard_room_world_size
	
	# Add scaled player position onto the map offset position
	player_icon.position = map_sprite.position + (player_local * scale_ratio)
	player_icon.visible = true

	# 5. Center the RoomContainer on the target sprite dynamically using viewport size
	var viewport_container = $SubViewportContainer as SubViewportContainer
	var viewport_center = viewport_container.size * 0.5
	var current_scale = room_container.scale.x
	room_container.position = viewport_center - (map_sprite.position * current_scale)
	
	_clamp_container_offset()

# --- PAN & ZOOM INPUT HANDLING ---

func _gui_input(event: InputEvent) -> void:
	# Handle Mouse Wheel Zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 - zoom_speed)
			
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	# Handle Touch Screen Inputs
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			dragging = true
		else:
			touch_points.erase(event.index)
			if touch_points.is_empty():
				dragging = false
			last_pinch_distance = 0.0 
			
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
		
		# CASE 1: Two-finger pinch-to-zoom
		if touch_points.size() == 2:
			var keys = touch_points.keys()
			var p1 = touch_points[keys[0]]
			var p2 = touch_points[keys[1]]
			var current_distance = p1.distance_to(p2)
			
			if last_pinch_distance > 0.0:
				var zoom_factor = current_distance / last_pinch_distance
				var pinch_center = (p1 + p2) * 0.5
				_zoom_at(pinch_center, zoom_factor)
				
			last_pinch_distance = current_distance
			
		# CASE 2: Single-finger pan/drag
		elif touch_points.size() <= 1 and dragging:
			room_container.position += event.relative
			_clamp_container_offset()
			last_pinch_distance = 0.0

	elif event is InputEventMouseMotion and dragging and touch_points.size() == 0:
		room_container.position += event.relative
		_clamp_container_offset()

func _zoom_at(zoom_pivot: Vector2, zoom_factor: float) -> void:
	var old_zoom = room_container.scale.x
	var new_zoom = clamp(old_zoom * zoom_factor, min_zoom, max_zoom)
	
	if new_zoom == old_zoom:
		return
		
	var viewport_container = $SubViewportContainer as SubViewportContainer
	var target_center = viewport_container.size * 0.5
	
	var zoom_pivot_local = target_center - room_container.position
	room_container.position -= zoom_pivot_local * (new_zoom / old_zoom - 1.0)
	room_container.scale = Vector2(new_zoom, new_zoom)
	
	_clamp_container_offset()

func _clamp_container_offset() -> void:
	var current_zoom = room_container.scale.x
	var viewport_container = $SubViewportContainer as SubViewportContainer
	var base_center = viewport_container.size * 0.5
	
	var current_range_x = max_drag_range_x * current_zoom
	var current_range_y = max_drag_range_y * current_zoom
	
	room_container.position.x = clamp(room_container.position.x, base_center.x - current_range_x, base_center.x + current_range_x)
	room_container.position.y = clamp(room_container.position.y, base_center.y - current_range_y, base_center.y + current_range_y)
