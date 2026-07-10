extends Node

signal room_change_requested(exit_id: int)

signal player_health_changed(new_health: int)
signal player_max_health_changed(new_max: int)
signal player_died
