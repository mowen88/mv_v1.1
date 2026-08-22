extends Control

# Adjust these paths to match your actual node names in the scene tree
@onready var quest_list_vbox: VBoxContainer = $HBoxContainer/ScrollContainer/VBoxContainer
@onready var title_label: Label = $HBoxContainer/DetailPanel/TitleLabel
@onready var status_label: Label = $HBoxContainer/DetailPanel/StatusLabel
@onready var desc_label: Label = $HBoxContainer/DetailPanel/DescriptionLabel

@export var ICON_IN_PROGRESS: Texture
@export var ICON_COMPLETED: Texture

# Dictionary containing titles and descriptions for your quests
const QUEST_DETAILS: Dictionary = {
	"find_the_key": {
		"title": "The Lost Key",
		"description": "Find the rusty key hidden deep in the lower caverns to unlock the heavy gate."
	},
	"defeat_boss": {
		"title": "Defeat The Slime King",
		"description": "Slay the ruler of the sludge depths to clear the path forward."
	}
}

func _ready() -> void:
	populate_quest_ui()

func populate_quest_ui() -> void:
	
	# Clear out any existing rows
	for child in quest_list_vbox.get_children():
		child.queue_free()

	# Loop through quests in the manager
	for quest_id in QuestManager.DEFAULT_QUEST_STATES.keys():
		var state = QuestManager.get_quest_state(quest_id)
		var details = QUEST_DETAILS.get(quest_id, {"title": quest_id, "description": "No description available."})
		
		## Only populate if quest is active
		#if state.to_lower() == "inactive":
			#continue
			#
		# Create a button dynamically for the row
		var row_button = Button.new()
		row_button.text = details["title"]# + " (" + state.capitalize() + ")"
		#row_button.custom_minimum_size = Vector2(100, 50) # Added a minimum width just in case
		row_button.alignment = HORIZONTAL_ALIGNMENT_LEFT

		match state.to_lower():
			"active":
				row_button.icon = ICON_IN_PROGRESS
			"completed":
				row_button.icon = ICON_COMPLETED
				
		# Connect the press event to update the right panel
		row_button.pressed.connect(func(): 
			display_quest_details(details["title"], state, details["description"])
		)
		
		quest_list_vbox.add_child(row_button)

func display_quest_details(q_title: String, q_state: String, q_desc: String) -> void:
	title_label.text = q_title
	status_label.text = "STATUS: " + q_state.to_upper()
	desc_label.text = q_desc
