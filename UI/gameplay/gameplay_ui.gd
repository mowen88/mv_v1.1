#extends CanvasLayer
#
#@onready var health_label: Label = $HealthLabel
#@onready var mana_bar: ProgressBar = $ManaBar
#
#func _ready() -> void:
	#SignalBus.player_health_changed.connect(_on_player_health_changed)
#
#func _on_player_health_changed(new_health: int) -> void:
	#health_label.text = "HP: " + str(new_health)
	#
	## You can easily add more logic here, like flashing the label red
	#if new_health <= 1:
		#health_label.modulate = Color.RED

extends CanvasLayer

@onready var health_hud: HBoxContainer = $HealthHUD
var health_mask_scene = preload("res://UI/gameplay/health_node_scene.tscn") # Make a small scene with a TextureRect

func _ready() -> void:
	# Assuming you can access max_health via SignalBus or a global
	var max_h = 5 # You can pull this from your player or a global state
	
	for i in range(max_h):
		var new_mask = health_mask_scene.instantiate()
		new_mask.texture = preload("res://UI/gameplay/elements/health_node_full.png")
		new_mask.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST 
		#new_mask.scale = Vector2(9,9)
		new_mask.custom_minimum_size = new_mask.texture.get_size() * 9
		health_hud.add_child(new_mask)
	
	SignalBus.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
	
	
	var masks = health_hud.get_children()
	
	var full_tex = preload("res://UI/gameplay/elements/health_node_full.png")
	var empty_tex = preload("res://UI/gameplay/elements/health_node_empty.png")
	
	for i in range(masks.size()):
		var mask_node = masks[i]
		if i < new_health:
			masks[i].texture = full_tex
		else:
			masks[i].texture = empty_tex
		
		mask_node.queue_redraw()
