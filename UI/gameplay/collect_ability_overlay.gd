extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var underline: Line2D = $VBoxContainer/Spacer/Line2D
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var detail_sprite: AnimatedSprite2D = $VBoxContainer/AnimationContainer/SpriteAnchor/AnimatedSprite2D
@onready var continue_label: Label = $VBoxContainer/ContinueLabel

signal unpause_requested

var waiting_for_input: bool = false

func _ready() -> void:
	visible = false # Hide by default on startup
	color_rect.modulate.a = 0.0
	vbox.modulate.a = 0.0
	continue_label.modulate.a = 0.0
	SignalBus.toggle_collect_ability_ui.connect(_on_toggle_collect_ability_ui)

func _input(event: InputEvent) -> void:
	if not waiting_for_input or not visible:
		return
		
	# Listen for any key press, mouse click, or mobile screen touch
	if event.is_action_pressed("ui_accept") or \
	   (event is InputEventScreenTouch and event.pressed):
		waiting_for_input = false
		
		# Fade out the background and contents smoothly before unpausing
		var fade_out_tween = create_tween().set_parallel(true)
		fade_out_tween.tween_property(color_rect, "modulate:a", 0.0, 0.25)
		fade_out_tween.tween_property(vbox, "modulate:a", 0.0, 0.25)
		await fade_out_tween.finished
		
		unpause_requested.emit()

func _on_toggle_collect_ability_ui(val: bool, ability_name: String) -> void:
	if val:
		visible = true
		color_rect.modulate.a = 0.0
		vbox.modulate.a = 0.0
		continue_label.modulate.a = 0.0
		
		# 0. Immediately reset underline points to center so it starts fresh
		underline.points = PackedVector2Array([
			Vector2(1170.0, 12.0),
			Vector2(1170.0, 12.0)
		])
		
		# 1. Update text and description based on the ability name
		title_label.text = ability_name
		if DialogueData.ABILITY_DETAILS.has(ability_name):
			description_label.text = DialogueData.ABILITY_DETAILS[ability_name]
		else:
			description_label.text = "A powerful newly unlocked ability."
			
		# 2. Force sprite animation update and reset frame
		if detail_sprite:
			if detail_sprite.sprite_frames and detail_sprite.sprite_frames.has_animation(ability_name):
				detail_sprite.visible = true
				detail_sprite.animation = ability_name
				detail_sprite.set_frame_and_progress(0, 0.0)
				detail_sprite.play()
			else:
				detail_sprite.visible = false
				detail_sprite.stop()
			
		# 3. Fade in the background ColorRect and contents together
		var fade_tween = create_tween().set_parallel(true)
		fade_tween.tween_property(color_rect, "modulate:a", 1.0, 0.3)
		fade_tween.tween_property(vbox, "modulate:a", 1.0, 0.3)
		await fade_tween.finished
		
		# 4. Wait one frame for layout calculation
		await get_tree().process_frame
		
		# 5. Expand the underline outwards from center
		await expand_underline()
		
		# 6. Wait for 2.0 seconds in real-time (ignoring game pause)
		await get_tree().create_timer(2.0, true, false, true).timeout
		
		# 7. Fade in the continue label
		var continue_tween = create_tween()
		continue_tween.tween_property(continue_label, "modulate:a", 1.0, 0.4)
		await continue_tween.finished
		
		# 8. Enable input listening to close on keypress/touch
		waiting_for_input = true
	else:
		waiting_for_input = false
		if detail_sprite:
			detail_sprite.stop()
		detail_sprite.visible = false
		
		# Reset underline to center points instantly on exit
		underline.points = PackedVector2Array([
			Vector2(1170.0, 12.0),
			Vector2(1170.0, 12.0)
		])
		
		visible = false

# Underline animate Function

func expand_underline() -> Signal:
	var helper = UnderlineExpandHelper.new()
	helper.underline = underline
	var tween = create_tween()
	tween.tween_property(helper, "progress", 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween.finished

# Underline helper

class UnderlineExpandHelper extends RefCounted:
	var underline: Line2D
	var progress: float = 0.0:
		set(val):
			progress = val
			var center_x = 1170.0
			var line_y = 12.0
			var cur_left = lerp(center_x, 0.0, progress)
			var cur_right = lerp(center_x, 2340.0, progress)
			if underline:
				underline.points = PackedVector2Array([
					Vector2(cur_left, line_y),
					Vector2(cur_right, line_y)
				])
