extends Sprite2D

@export var exit_id: int = 0

@onready var interaction_component: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction_component.interact.connect(_on_door_interacted)

func _on_door_interacted(player: CharacterBody2D) -> void:
	# Make sure player is on ground and not moving too fast before leaving
	if abs(player.velocity.x) < 10 and player.is_on_floor():
	
		# Set player state to enter door
		player.fsm.change_state("EnterDoor")
		
		# Create slide tween
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

		# Slide to the center of the door
		tween.tween_property(player, "global_position:x", global_position.x, 0.8)
		
		# Wait for tween to finish
		await tween.finished
		
		# Change state and start new room
		player.fsm.change_state("ExitDoor")
		SignalBus.room_change_requested.emit(exit_id)
