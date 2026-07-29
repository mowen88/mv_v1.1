extends Node

signal camera_override_cleared
signal camera_override_requested(target:Vector2, lock_x:bool, lock_y:bool)

signal room_change_requested(exit_id: int)
signal save_station_activated

signal zone_banner_requested(zone_name: String)
signal tutorial_message_requested(message:String)

signal screenshake_requested(x_offset:float, y_offset:float, duration:float)

signal player_health_changed(new_health: int)
signal player_max_health_changed(new_max: int)
signal player_died

signal player_energy_changed(new_energy: int)
signal player_max_energy_changed(new_max: int)

signal player_energy_gained(entity: Node2D)
signal player_respawn(position:Vector2)
signal hit_hazard(entity:Node2D, damage:float)
