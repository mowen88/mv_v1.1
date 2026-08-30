extends Control

const ITEM_ROW_SCENE = preload("res://UI/gameplay/PauseMenu/ItemRowScene.tscn")

@onready var ability_container: GridContainer = $HBoxContainer/StatusPanel/VBoxContainer/GridContainer
@onready var items_container: VBoxContainer = $HBoxContainer/ScrollPanel/ScrollContainer/VBoxContainer
@onready var detail_title_label: Label = $HBoxContainer/DetailPanel/TitleLabel
@onready var detail_description_label: Label = $HBoxContainer/DetailPanel/DescriptionLabel

# Map your ability keys directly to the TextureButton nodes in the scene tree
@onready var ability_buttons: Dictionary = {
	"Glide": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/GlideSlot/TextureButton"),
	"Jump Attack": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/JumpAttackSlot/TextureButton"),
	"Water Walk": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/WaterWalkSlot/TextureButton"),
	"Ground Slam": get_node_or_null("HBoxContainer/StatusPanel/VBoxContainer/GridContainer/GroundSlamSlot/TextureButton"),
}

const ABILITY_DETAILS: Dictionary = {
	"Glide": "Allows you to glide smoothly through the air over long gaps.",
	"Jump Attack": "Perform a powerful downward strike while airborne.",
	"Water Walk": "Enables movement safely across the surface of deep water.",
	"Ground Slam": "Crash heavily into the ground to break cracked floors and stun nearby foes."
}

const ITEM_DETAILS: Dictionary = {
	"Key": "An ancient key covered in intricate engravings. It looks like it fits a heavy iron lock.",
	"Ruby": "A radiant red gemstone that pulses with a faint internal warmth.",
	"Stone": "A dense piece of carved masonry.",
	"Tablet": "Inscribed with ancient text detailing forgotten lore.",
	"Hankerchief": "A delicate piece of cloth embroidered with a faded crest.",
	"Rope": "A strong coil of braided fiber, roughly ten meters long.",
	"Candle": "A thick wax candle that provides a small radius of warm light."
}

func _ready() -> void:
	# Connect the press signal for each button on startup so clicking them updates your details pane
	for ability_name in ability_buttons.keys():
		var btn = ability_buttons[ability_name]
		if btn is BaseButton:
			btn.pressed.connect(_on_ability_button_pressed.bind(ability_name))

# Single func to run in the main inventory overlay when opening
func update_current_details()-> void:
	populate_abilities()
	populate_items()

func populate_abilities() -> void:
	# Hide texture buttons by default when open inventory
	for node in ability_buttons.values():
		if node:
			node.visible = false

	var slot_data = SaveManager.SAVE_DATA[SaveManager.current_slot]
	if not slot_data.has("abilities"):
		return
		
	# Show matching texture button 
	for ability_name in slot_data["abilities"].keys():
		if slot_data["abilities"][ability_name] == true:
			if ability_buttons.has(ability_name) and ability_buttons[ability_name] is Control:
				ability_buttons[ability_name].visible = true

func populate_items() -> void:
	# 1. Clear out old item rows
	for child in items_container.get_children():
		child.queue_free()

	if not SaveManager.SAVE_DATA.has(SaveManager.current_slot):
		return
		
	var slot_data = SaveManager.SAVE_DATA[SaveManager.current_slot]
	if not slot_data.has("items") or slot_data["items"].is_empty():
		return
		
	var saved_items: Dictionary = slot_data["items"]
	
	# 2. Instantiate a fresh row for each collected item
	for item_name in saved_items.keys():
		var quantity = int(saved_items[item_name])
		if quantity <= 0:
			continue
			
		var row_instance = ITEM_ROW_SCENE.instantiate() as HBoxContainer
		
		# Look up the name node as a BaseButton (since you changed it from a Label to a Button)
		var name_button = row_instance.get_node_or_null("ItemNameButton") as Button
		var count_label = row_instance.get_node_or_null("ItemCountLabel") as Label
		
		if name_button:
			name_button.text = item_name
			# Connect the button press signal to your handler, passing the item name
			name_button.pressed.connect(_on_item_button_pressed.bind(item_name))
			
		if count_label:
			count_label.text = "x %d" % quantity
			
		items_container.add_child(row_instance)

func _on_item_button_pressed(item_name: String) -> void:
	print("Clicked item button: ", item_name)
	
	if detail_title_label:
		detail_title_label.text = item_name
	
	if detail_description_label:
		if ITEM_DETAILS.has(item_name):
			detail_description_label.text = ITEM_DETAILS[item_name]
		else:
			detail_description_label.text = "A mysterious item collected during your journey."
			
func _on_ability_button_pressed(ability_name: String) -> void:
	print("Clicked ability button: ", ability_name)
	
	if detail_title_label:
		detail_title_label.text = ability_name
		
	if detail_description_label:
		if ABILITY_DETAILS.has(ability_name):
			detail_description_label.text = ABILITY_DETAILS[ability_name]
		else:
			detail_description_label.text = "A powerful unlocked ability."
