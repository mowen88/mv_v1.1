extends Node

signal room_change_requested(exit_id: int)

signal player_health_changed(new_health: int)
signal player_max_health_changed(new_max: int)
signal player_died

signal player_energy_changed(new_energy: int)
signal player_max_energy_changed(new_max: int)

signal player_energy_gained(entity: Node2D, knockback_force: float)
