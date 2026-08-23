extends Control

# Adjust these paths to match your actual node names in the scene tree
@onready var quest_list_vbox: VBoxContainer = $HBoxContainer/ScrollPanel/ScrollContainer/VBoxContainer
@onready var detail_panel: VBoxContainer = $HBoxContainer/DetailPanel
@onready var title_label: Label = $HBoxContainer/DetailPanel/TitleLabel
@onready var status_label: Label = $HBoxContainer/DetailPanel/StatusLabel
@onready var desc_label: Label = $HBoxContainer/DetailPanel/DescriptionLabel
@onready var reward_label: Label = $HBoxContainer/DetailPanel/RewardLabel

@export var ICON_IN_PROGRESS: Texture
@export var ICON_COMPLETED: Texture

# Dictionary containing titles and descriptions for your quests
const QUEST_DETAILS: Dictionary = {
	"find_the_key": {
		"title": "The Lost Key is a long line of text",
		"description": "Find the rusty key hidden deep in the lower caverns to unlock the heavy gate.",
		"reward": "A really long sentence to test the box padding of this reward text box"
	},
	"defeat_boss": {
		"title": "Defeat The Slime King",
		"description": "Slay the ruler of the sludge depths to clear the path forward.",
		"reward": "Gain access to the tomb!"
	},
		"find_the_boss": {
		"title": "The Lost Key",
		"description": "Find the rusty key hidden deep in the lower caverns to unlock the heavy gate.",
		"reward": "Gain access to the tomb!"
	},
	"defeat_dude": {
		"title": "Defeat The Slime King",
		"description": "Slay the ruler of the sludge depths to clear the path forward.",
		"reward": "Gain access to the tomb!"
	},
		"death_quest": {
		"title": "Defeat The Slime King",
		"description": "Slay the ruler of the sludge depths to clear the path forward.",
		"reward": "Gain access to the tomb!"
	}
}

func _ready() -> void:
	populate_quest_ui()

func update_current_details() -> void:
	# Update quest list first
	populate_quest_ui()
	# Check latest quest details to show correctly when opening - called in invetory overlay script
	for quest_id in QUEST_DETAILS.keys():
		var details = QUEST_DETAILS[quest_id]
		if details["title"] == title_label.text:
			var live_state = QuestManager.get_quest_state(quest_id)
			display_quest_details(details["title"], live_state, details["description"], details["reward"])
			return

func populate_quest_ui() -> void:
	
	# Clear out any existing rows
	for child in quest_list_vbox.get_children():
		child.queue_free()

	# Loop through quests in the manager
	for quest_id in QuestManager.DEFAULT_QUEST_STATES.keys():
		var state = QuestManager.get_quest_state(quest_id)
		var details = QUEST_DETAILS.get(quest_id, {"title": quest_id, "description": "No description available."})
		
		# Only populate if quest is active
		#if state.to_lower() == "inactive":
			#continue
			
		# Create a button dynamically for the row
		var row_button = Button.new()
		row_button.text = details["title"]
		row_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row_button.mouse_filter = Control.MOUSE_FILTER_PASS
		row_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		match state:
			"In progress":
				row_button.icon = ICON_IN_PROGRESS
			"Completed":
				row_button.icon = ICON_COMPLETED
			"Inactive":
				row_button.icon = ICON_IN_PROGRESS
		
		var empty_style = StyleBoxEmpty.new()
		row_button.add_theme_stylebox_override("normal", empty_style)
		row_button.add_theme_stylebox_override("hover", empty_style)
		row_button.add_theme_stylebox_override("pressed", empty_style)
		row_button.add_theme_stylebox_override("focus", empty_style)
		
		# Connect the press event to update the right panel
		row_button.pressed.connect(func(): 
			display_quest_details(details["title"], state, details["description"], details["reward"])
		)
		
		quest_list_vbox.add_child(row_button)

func display_quest_details(q_title:String, q_state:String, q_desc:String, q_reward:String) -> void:
		
	title_label.text = q_title
	status_label.text = q_state
	desc_label.text = q_desc
	reward_label.text = "REWARD :  " + q_reward
	
	match q_state:
		"In progress":
			status_label.add_theme_color_override("font_color", Color8(255, 189, 111))   # Yellow/In Progress
		"Completed":
			status_label.add_theme_color_override("font_color", Color8(121, 181, 71)) # Green/Completed
		"Inactive":
			status_label.add_theme_color_override("font_color", Color8(229, 88, 88))   # Red
