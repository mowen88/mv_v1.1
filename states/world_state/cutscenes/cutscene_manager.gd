extends CanvasLayer

@onready var choice_container: Container = $ChoiceContainer # Or wherever you placed it
@onready var button_a: Button = $ChoiceContainer/ButtonA
@onready var button_b: Button = $ChoiceContainer/ButtonB

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar
@onready var text_label: RichTextLabel = $BottomBar/RichTextLabel

@export var bar_height: float = 120.0
@export var player: Node2D
@export var typing_speed: float = 0.03

var is_playing: bool = false
var waiting_for_input: bool = false
var is_typing: bool = false
var current_tween: Tween = null

var selected_choice_index: int = -1

func _ready() -> void:
	var screen_height = float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	top_bar.position.y = -bar_height
	bottom_bar.position.y = screen_height
	text_label.text = ""
	
	SignalBus.play_cutscene.connect(_on_play_cutscene)
	button_a.pressed.connect(_on_button_a_pressed)
	button_b.pressed.connect(_on_button_b_pressed)

func _on_button_a_pressed() -> void:
	selected_choice_index = 0

func _on_button_b_pressed() -> void:
	selected_choice_index = 1	

# Captures input to skip typing, advance lines, or close the cutscene
func _input(event: InputEvent) -> void:
	if not is_playing or not waiting_for_input:
		return
		
	if event.is_action_pressed("ui_accept"):
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
		if player.has_node("FiniteStateMachine"):
			player.get_node("FiniteStateMachine").change_state("Idle")
		
	await toggle_bars(true)
	
	for item in sequence:
		# CASE 1: The item is a normal text string
		if item is String:
			text_label.text = item
			text_label.visible_ratio = 0.0
			is_typing = true
			waiting_for_input = true
			
			var text_duration = max(0.5, item.length() * typing_speed)
			current_tween = create_tween()
			current_tween.tween_property(text_label, "visible_ratio", 1.0, text_duration)
			
			await current_tween.finished
			is_typing = false
			
			while waiting_for_input:
				await get_tree().process_frame
				
		# CASE 2: The item is a choice dictionary
		elif item is Dictionary:
			text_label.text = item.get("text", "")
			text_label.visible_ratio = 1.0 # Show prompt text instantly
			
			var choices = item.get("choices", ["Yes", "No"])
			button_a.text = choices[0] if choices.size() > 0 else "Yes"
			button_b.text = choices[1] if choices.size() > 1 else "No"
			
			choice_container.visible = true
			selected_choice_index = -1
			
			while selected_choice_index == -1:
				await get_tree().process_frame
				
			choice_container.visible = false
			
			# BRANCH HANDLING: Check if this choice has a specific branch attached
			var branches = item.get("branches", [])
			if branches.size() > selected_choice_index:
				var chosen_branch = branches[selected_choice_index]
				
				# Play the sub-sequence for the chosen path line-by-line
				for branch_line in chosen_branch:
					text_label.text = branch_line
					text_label.visible_ratio = 0.0
					is_typing = true
					waiting_for_input = true
					
					var b_duration = max(0.5, branch_line.length() * typing_speed)
					current_tween = create_tween()
					current_tween.tween_property(text_label, "visible_ratio", 1.0, b_duration)
					
					await current_tween.finished
					is_typing = false
					
					while waiting_for_input:
						await get_tree().process_frame
	text_label.text = ""
	await toggle_bars(false)
	
	InputManager.cutscene_lock = false
	is_playing = false
	
func toggle_bars(open: bool) -> void:
	var duration = 0.7
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var screen_height = float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	
	if open:
		tween.tween_property(top_bar, "position:y", 0.0, duration)
		tween.tween_property(bottom_bar, "position:y", screen_height - bar_height, duration)
	else:
		tween.tween_property(top_bar, "position:y", -bar_height, duration)
		tween.tween_property(bottom_bar, "position:y", screen_height, duration)
		
	await tween.finished
