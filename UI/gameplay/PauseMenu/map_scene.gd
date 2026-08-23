extends Control

@onready var room_container: Node2D = $SubViewportContainer/SubViewport/RoomContainer

# Zoom configuration
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_speed: float = 0.1

# Touch/Drag tracking variables
var dragging: bool = false
var touch_points: Dictionary = {}

func update_map_display(current_room:String, _player_node:Node2D) -> void:
	print(current_room)
	# 1. Get visited rooms from save data
	var visited_rooms = []
	if SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		visited_rooms = SaveManager.SAVE_DATA[SaveManager.current_slot].get("visited_rooms", [])

	# Loop through all Sprite2D child nodes inside RoomContainer
	for room_node in room_container.get_children():
		if room_node is Sprite2D:
			var room_id = room_node.name.to_lower()
			
			# Check if visited
			var is_visited = true
			for visited in visited_rooms:
				if visited.to_lower() == room_id:
					is_visited = false
					break
			
			# Visibility logic based on save progression
			room_node.visible = is_visited


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

	# Handle Touch Drag / Pinch Input
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
			
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
		
		if touch_points.size() <= 1 and dragging:
			room_container.position += event.relative

	elif event is InputEventMouseMotion and dragging and touch_points.size() == 0:
		room_container.position += event.relative

func _zoom_at(mouse_pos: Vector2, zoom_factor: float) -> void:
	var old_zoom = room_container.scale.x
	var new_zoom = clamp(old_zoom * zoom_factor, min_zoom, max_zoom)
	
	if new_zoom == old_zoom:
		return
		
	var zoom_pivot = mouse_pos - room_container.position
	room_container.position -= zoom_pivot * (new_zoom / old_zoom - 1.0)
	room_container.scale = Vector2(new_zoom, new_zoom)
