class_name EnergyComponent
extends Node

signal energy_changed(new_energy: int)
signal max_energy_changed(new_max: int)

@export var max_energy: int = 99:
	set(value):
		max_energy = value
		max_energy_changed.emit(max_energy)

@onready var current_energy: int = 0

func gain_energy(amount: int) -> void:
	current_energy = clampi(current_energy + amount, 0, max_energy)
	energy_changed.emit(current_energy)

func consume_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		energy_changed.emit(current_energy)
		return true
	return false
