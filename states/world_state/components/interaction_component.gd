extends Area2D
class_name InteractionComponent

signal interact(player: CharacterBody2D)

@export var prompt_text: String = "Interact here!"
# Set a visual root with scale down to 0.1 so pixel offset
# will look clean with the text not being on canvas layer
@onready var interact_label: Label = $VisualRoot/InteractLabel
@onready var swipe_icon: Sprite2D = $SwipeIcon

var player: CharacterBody2D
var bounce_tween: Tween
var base_swipe_y: float

func _ready() -> void:
	interact_label.text = prompt_text
	base_swipe_y = swipe_icon.position.y

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	set_ui_visible(false)
	set_ui_alpha(0.0)
	
	SignalBus.swipe_up_detected.connect(_trigger_interaction)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		set_ui_visible(true)
		fade_ui(1.0, 0.2)
		start_bounce()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		kill_bounce()
		var tween = fade_ui(0.0, 0.2)
		await tween.finished
		set_ui_visible(false)

func _trigger_interaction()-> void:
	if InputManager.input_lock:
		return
		
	# Make sure player is on ground and not moving too fast before leaving
	# Only trigger if the player is in range and the prompt is visible
	if interact_label.visible:
		if abs(player.velocity.x) < 10 and player.is_on_floor():
			kill_bounce()	
			interact.emit(player)
			fade_ui(0.0, 0.3)

func _unhandled_input(event:InputEvent)-> void:
	if event.is_action_pressed("up"):
		_trigger_interaction()

# Helper functions....
func start_bounce() -> void:
	if bounce_tween and bounce_tween.is_running():
		return
		
	bounce_tween = create_tween().set_loops()
	bounce_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(swipe_icon, "position:y", base_swipe_y - 6.0, 0.4)
	bounce_tween.tween_property(swipe_icon, "position:y", base_swipe_y, 0.4)

func set_ui_visible(new_visibility: bool) -> void:
	interact_label.visible = new_visibility
	swipe_icon.visible = new_visibility

func set_ui_alpha(alpha: float) -> void:
	interact_label.modulate.a = alpha
	swipe_icon.modulate.a = alpha

func fade_ui(target_alpha: float, duration: float) -> Tween:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(interact_label, "modulate:a", target_alpha, duration)
	tween.tween_property(swipe_icon, "modulate:a", target_alpha, duration)
	return tween

func kill_bounce() -> void:
	if bounce_tween:
		bounce_tween.kill()
