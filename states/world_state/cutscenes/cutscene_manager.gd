extends CanvasLayer

@onready var typing_sound: AudioStreamPlayer = $TypingSound

@onready var choice_container: Container = $ChoiceContainer
@onready var button_a: Button = $ChoiceContainer/ButtonAContainer/ButtonA
@onready var button_b: Button = $ChoiceContainer/ButtonBContainer/ButtonB

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar
@onready var text_label: RichTextLabel = $BottomBar/RichTextLabel

@export var player: Node2D
@export var typing_speed: float = 0.03

@export var select_sound: AudioStream
@export var back_sound: AudioStream

# Preset dimensions
var screen_height:float = ProjectSettings.get_setting("display/window/size/viewport_height")
var bar_height: float

var is_playing: bool = false
var waiting_for_input: bool = false
var is_typing: bool = false
var current_tween: Tween = null

var selected_choice_index: int = -1
var current_quest_context_id: String = ""

func _ready() -> void:
	bar_height = top_bar.size.y
	top_bar.position.y = -bar_height
	bottom_bar.position.y = screen_height
	text_label.text = ""
	
	SignalBus.play_cutscene.connect(_on_play_cutscene)
	button_a.pressed.connect(_on_button_a_pressed)
	button_b.pressed.connect(_on_button_b_pressed)

func _on_button_a_pressed() -> void:
	AudioManager.play_sfx(select_sound)
	selected_choice_index = 0

func _on_button_b_pressed() -> void:
	AudioManager.play_sfx(back_sound)
	selected_choice_index = 1	

# Captures input to skip typing, advance lines, or close the cutscene
func _input(event: InputEvent) -> void:
	if not is_playing or not waiting_for_input:
		return
	
	# Check for keyboard/gamepad action OR a mobile touchscreen tap
	var is_accept = event.is_action_pressed("ui_accept")
	var is_touch = event is InputEventScreenTouch and event.pressed
		
	if is_accept or is_touch:
		if is_typing:
			# 1. If text is still typing, finish it instantly
			if current_tween and current_tween.is_valid():
				current_tween.custom_step(999.0)
		else:
			# 2. If text is fully visible, move to the next line or finish
			waiting_for_input = false

func _on_play_cutscene(cutscene_name: String) -> void:
	if is_playing:
		return
		
	if DialogueData.DATABASE.has(cutscene_name):
		var sequence = DialogueData.DATABASE[cutscene_name]
		await run_cutscene(sequence)
	else:
		push_warning("Cutscene or Dialogue key not found: " + cutscene_name)

func run_cutscene(sequence: Array) -> void:
	is_playing = true
	
	InputManager.cutscene_lock = true
	if player:
		player.move_component.direction = 0.0
		player.velocity.x = 0.0
		player.fsm.change_state("Idle")
		
	await toggle_bars(true)
	
	for item in sequence:
		# CASE 1: Normal text string
		if item is String:
			await type_line(item, true)
				
		# CASE 2: Choice dictionary (Player picks)
		elif item is Dictionary and item.has("choices"):
			var question_text = item.get("text", "")
			await type_line(question_text, false)
			
			var choices = item.get("choices", ["Yes", "No"])
			button_a.text = choices[0] if choices.size() > 0 else "Yes"
			button_b.text = choices[1] if choices.size() > 1 else "No"
			
			selected_choice_index = -1
			await tween_choice_container(true)
			
			while selected_choice_index == -1:
				await get_tree().process_frame
				
			await tween_choice_container(false)
			
			# --- QUEST ACCEPTANCE HOOK ---
			# If this choice prompt is part of the inactive quest branch, update quest state based on choice index!
			if current_quest_context_id != "":
				if selected_choice_index == 0:
					QuestManager.set_quest_state(current_quest_context_id, "in_progress")
				# Index 1 is decline, so we keep it inactive (or handle as needed)
			
			var branches = item.get("branches", [])
			if branches.size() > selected_choice_index:
				for branch_line in branches[selected_choice_index]:
					await type_line(branch_line, true)
					
			# Clear tracking variable after resolving choices
			current_quest_context_id = ""

		# CASE 3: Quest State Query (Automatic branch based on progress)
		elif item is Dictionary and item.get("type") == "quest_branch":
			var quest_id = item.get("quest_id", "")
			var current_state = QuestManager.get_quest_state(quest_id) 
			
			# Track which quest we are currently evaluating choices for
			current_quest_context_id = quest_id if current_state == "inactive" else ""
			
			var quest_branches = item.get("branches", {})
			if quest_branches.has(current_state):
				for line in quest_branches[current_state]:
					if line is String:
						await type_line(line, true)
					elif line is Dictionary and line.has("choices"):
						# Handles choice dictionary nested directly inside quest states
						var question_text = line.get("text", "")
						await type_line(question_text, false)
						
						var choices = line.get("choices", ["Yes", "No"])
						button_a.text = choices[0] if choices.size() > 0 else "Yes"
						button_b.text = choices[1] if choices.size() > 1 else "No"
						
						selected_choice_index = -1
						await tween_choice_container(true)
						
						while selected_choice_index == -1:
							await get_tree().process_frame
							
						await tween_choice_container(false)
						
						# If they picked choice 0 (Accept), update quest state immediately!
						if selected_choice_index == 0:
							QuestManager.set_quest_state(quest_id, "in_progress")
							
						var branches = line.get("branches", [])
						if branches.size() > selected_choice_index:
							for branch_line in branches[selected_choice_index]:
								await type_line(branch_line, true)
								
			current_quest_context_id = ""

	text_label.text = ""
	await toggle_bars(false)
	
	InputManager.cutscene_lock = false
	is_playing = false


# Helper function updated with a flag to optionally skip waiting for input
func type_line(content: String, wait_for_keypress: bool) -> void:
	text_label.text = content
	text_label.visible_ratio = 0.0
	is_typing = true
	waiting_for_input = true
	
	var text_duration = max(0.5, content.length() * typing_speed)
	current_tween = create_tween()
	current_tween.tween_property(text_label, "visible_ratio", 1.0, text_duration)
	
	# Play sound effect while typing
	if typing_sound.stream and not typing_sound.playing:
		typing_sound.play()
	
	await current_tween.finished
	
	# Stop the typing sound immediately when text finishes or is skipped
	if typing_sound.playing:
		typing_sound.stop()
		
	is_typing = false
	
	if not wait_for_keypress:
		waiting_for_input = false
		return
	
	while waiting_for_input:
		await get_tree().process_frame

func tween_choice_container(show_choices: bool) -> void:
	var target_y = screen_height/2 if show_choices else screen_height + 100
	
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(choice_container, "position:y", target_y, 1.0)
	
	if show_choices:
		choice_container.visible = true
		await tween.finished
	else:
		await tween.finished
		choice_container.visible = false
	
func toggle_bars(open: bool) -> void:
	var duration = 0.7
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if open:
		# Hide UIs straight away
		SignalBus.toggle_gameplay_ui.emit(false)
		SignalBus.toggle_touch_controller.emit(false)
		
		tween.tween_property(top_bar, "position:y", 0.0, duration)
		tween.tween_property(bottom_bar, "position:y", screen_height - bar_height, duration)
	else:
		tween.tween_property(top_bar, "position:y", -bar_height, duration)
		tween.tween_property(bottom_bar, "position:y", screen_height, duration)
	
	await tween.finished
	
	# Await finished black bars and then show UIs again
	if not open:	
		SignalBus.toggle_gameplay_ui.emit(true)
		SignalBus.toggle_touch_controller.emit(true)
		
	
