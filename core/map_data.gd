extends Node

# Typed dictionary: Keys are Strings (ids), values are Dictionaries
const ZONE_REGISTRY: Dictionary[String, Dictionary] = {
	"a": {
		"zone_name": "Enclave",
		"bgm": "res://states/world_state/music/enclave_theme.mp3"
	},
	"b": {
		"zone_name": "Temple",
		"bgm": "res://states/world_state/music/temple_theme.ogg"
	},
		"c": {
		"zone_name": "Grotto",
		"bgm": "res://states/world_state/music/temple_theme.ogg"
	}
}

const ROOM_REGISTRY: Dictionary[String, Dictionary] = {
	"01_a": {
		1: "01_b",
		2: "02_a",
		3: "01_c"
	},
	"02_a": {
		1: "01_c",
		2: "01_a",
		3: "02_c"
	},
	"01_b": {
		1: "01_a",
		2: "01_c"
	},
	"01_c": {
		1: "02_a",
		2: "01_b",
		3: "01_a"
	},
	"02_c": {
		0: "01_a",
		3: "02_a"
	}
}
