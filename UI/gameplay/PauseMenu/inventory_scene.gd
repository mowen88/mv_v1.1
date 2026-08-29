extends Control

@onready var grid_container: GridContainer = $HBoxContainer/StatusPanel/VBoxContainer/GridContainer

# Map your ability keys directly to the TextureButton nodes in the scene tree
@onready var ability_buttons: Dictionary = {
	"Glide": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/GlideSlot/TextureButton"),
	"Jump Attack": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/JumpAttackSlot/TextureButton"),
	"Water Walk": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/WaterWalkSlot/TextureButton"),
	"Ground Slam": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/GroundSlamSlot/TextureButton"),
}

func _ready() -> void:
	# Connect the press signal for each button on startup so clicking them updates your details pane
	for ability_name in ability_buttons.keys():
		var btn = ability_buttons[ability_name]
		if btn is BaseButton:
			btn.pressed.connect(_on_ability_button_pressed.bind(ability_name))
			
	populate_abilities()

func populate_abilities() -> void:
	# 1. Hide all texture buttons by default when opening the inventory
	for node in ability_buttons.values():
		if node is Control:
			node.visible = false

	if not SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		return
		
	var slot_data = SaveManager.SAVE_DATA[SaveManager.current_slot]
	if not slot_data.has("abilities"):
		return
		
	# 2. Show matching texture 
	for ability_name in slot_data["abilities"].keys():
		if slot_data["abilities"][ability_name] == true:
			if ability_buttons.has(ability_name) and ability_buttons[ability_name] is Control:
				ability_buttons[ability_name].visible = true

# 3. Triggers when an ability texture button is clicked
func _on_ability_button_pressed(ability_name: String) -> void:
	print("Clicked ability button: ", ability_name)
	
	# TODO: Hook up your details pane here to display info for this ability name
