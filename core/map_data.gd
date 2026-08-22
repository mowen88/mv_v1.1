extends Node

# Typed dictionary: Keys are Strings (ids), values are Dictionaries
const ZONE_REGISTRY: Dictionary[String, Dictionary] = {
	"a": {
		"zone_name": "The Summit",
		"bgm": "res://states/world_state/music/enclave_theme.mp3"
	},
	"b": {
		"zone_name": "Temple",
		"bgm": "res://states/world_state/music/temple_theme.ogg"
	},
		"c": {
		"zone_name": "Grotto",
	}
}

const ROOM_REGISTRY: Dictionary[String, Array] = {
	"The Summit":
		["a_01","a_02","a_03","a_04","a_05"],
	"Temple":
		["b_01","b_02","b_03","b_04","b_05"],
	"Aquaducts":
		["c_01","c_02","c_03","c_04","c_05"]
}
#const ROOM_REGISTRY: Dictionary[String, Dictionary] = {
	#"01_a": {
		#0: "02_c",
		#1: "01_b",
		#2: "02_a",
		#3: "01_c"
	#},
	#"02_a": {
		#1: "01_c",
		#2: "01_a",
		#3: "02_c"
	#},
	#"01_b": {
		#1: "01_a",
		#2: "01_c"
	#},
	#"01_c": {
		#1: "02_a",
		#2: "01_b",
		#3: "01_a"
	#},
	#"02_c": {
		#0: "01_a",
		#3: "02_a"
	#}
#}
