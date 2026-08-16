class_name NPC1
extends CharacterBody2D

#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var persistence_component: PersistenceComponent = $PersistenceComponent

var has_spoken: bool = false

func _ready() -> void:
	interaction_component.interact.connect(_on_interacted)
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)

func _on_interacted(_player: CharacterBody2D) -> void:
	
	SignalBus.play_cutscene.emit("test_quest")
	
	## name + state to fidn the correct dialogue entry in the database
	#var state_suffix = "_spoken" if has_spoken else "_initial"
	#var dialogue_key = persistence_component.persistent_id + state_suffix
	#
	#if not has_spoken:
		#persistence_component.add_to_peristent_list()
		#has_spoken = true
	#
	#SignalBus.play_cutscene.emit(dialogue_key)

func _on_persistent_state_loaded(_pos: Vector2) -> void:
	# This triggers on startup if the ID is already in persisten tlist
	has_spoken = true
	
	
