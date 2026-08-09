extends Node

signal swipe_down_detected
signal swipe_up_detected

signal camera_override_cleared
signal camera_override_requested(target:Vector2, lock_x:bool, lock_y:bool)
signal camera_zoom_requested(multiplier: float, duration: float)

signal room_change_requested(room_scene: PackedScene, exit_id: int)
signal enter_door_requested(room_scene: PackedScene, exit_id: int)
signal save_station_activated

signal zone_banner_requested(zone_name: String)
signal tutorial_message_requested(message:String)
signal show_interaction_prompt()
signal hide_interaction_prompt()

signal screenshake_requested(x_offset:float, y_offset:float, duration:float)
signal death_screen_fade(color:Color, duration:float)
signal flash_screen(color:Color, duration:float)
signal hit_stop_requested(duration: float)

signal player_health_changed(new_health: int)
signal player_max_health_changed(new_max: int)
signal player_died

signal player_energy_changed(new_energy: int)
signal player_max_energy_changed(new_max: int)

signal player_energy_gained(entity: Node2D)
signal player_respawn(position:Vector2)

signal trap_doors_unlocked(_id:String)
