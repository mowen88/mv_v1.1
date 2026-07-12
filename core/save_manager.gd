extends Node

var current_slot: String = "1"

var SAVE_DATA: Dictionary[String, Dictionary] = {
	"1":{
		"enemies_dead":[],
		"bosses_dead":[],
		"collected_items":[],
		"broken_walls":[],
		"player_data":{"room_id":"01_a",
						"collected_items":[],
						"health":5,
						"max_health":5,
						"energy": 5}
	},
	
	"2":{
		"enemies_dead":[],
		"bosses_dead":[],
		"collected_items":[],
		"broken_walls":[],
		"player_data":{"room_id":"01_a",
						"collected_items":[],
						"health":5,
						"max_health":5,
						"energy": 5}
	},
	
	
	"3":{
		"enemies_dead":[],
		"bosses_dead":[],
		"collected_items":[],
		"broken_walls":[],
		"player_data":{"room_id":"01_a",
						"collected_items":[],
						"health":5,
						"max_health":5,
						"energy": 5}
	},
	
}

# Updates the save profile with the last room visited and fully replenishes player stats
func save_at_station(room_name: String) -> void:
	var p_data = SAVE_DATA[current_slot]["player_data"]
	p_data["room_id"] = room_name
	print("Game successfully saved at room: ", room_name)

func get_saved_room() -> String:
	return SAVE_DATA[current_slot]["player_data"]["room_id"]

func get_saved_player_data() -> Dictionary:
	return SAVE_DATA[current_slot]["player_data"]
