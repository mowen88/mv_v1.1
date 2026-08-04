extends Sprite2D

@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var swipe_icon: Sprite2D = $SwipeIcon

var bounce_tween: Tween
var base_swipe_y: float

func _ready() -> void:
	interaction_component.interact.connect(_on_save_station_interacted)
	
	# Save the relative y position
	base_swipe_y = swipe_icon.position.y

func _process(_delta: float) -> void:
	# Match swipe_icon visibility and fade to match InteractionComponent's label if it exists
	var label = interaction_component.get_node_or_null("InteractLabel")
	if label:
		swipe_icon.visible = label.visible
		swipe_icon.modulate.a = label.modulate.a
		
		if label.visible and label.modulate.a > 0.0:
			if not bounce_tween or not bounce_tween.is_running():
				start_bounce()
		else:
			if bounce_tween:
				bounce_tween.kill()

func start_bounce() -> void:
	if bounce_tween and bounce_tween.is_running():
		return
		
	bounce_tween = create_tween().set_loops()
	bounce_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(swipe_icon, "position:y", base_swipe_y - 6.0, 0.4)
	bounce_tween.tween_property(swipe_icon, "position:y", base_swipe_y, 0.4)

func _on_save_station_interacted(player: CharacterBody2D) -> void:
	# Make sure player is on ground and not moving too fast before leaving
	if abs(player.velocity.x) < 10 and player.is_on_floor():
		
		# Stop bouncing and hide icon immediately on interaction
		if bounce_tween:
			bounce_tween.kill()
		
		ParticleManager.play("hit_effect", interaction_component.global_position)
		player.flash_component.play_flash()
		SignalBus.tutorial_message_requested.emit("Game Saved")
		SignalBus.save_station_activated.emit()
