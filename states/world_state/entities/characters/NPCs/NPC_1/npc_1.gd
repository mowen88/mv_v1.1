class_name NPC1
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var interaction_component: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction_component.interact.connect(_on_interacted)
	

func _on_interacted(_player:CharacterBody2D):
	SignalBus.play_cutscene.emit("test_quest")
	#SignalBus.play_cutscene.emit("test_intro")
	
	
