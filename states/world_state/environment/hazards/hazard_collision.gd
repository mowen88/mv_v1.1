extends Node2D

@export var damage:float = 1.0
@onready var hitbox_component: HitboxComponent = $HitboxComponent

func _ready() -> void:
	hitbox_component.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	SignalBus.hit_hazard.emit(body, damage)
