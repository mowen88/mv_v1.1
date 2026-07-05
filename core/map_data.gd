extends Node

# Typed dictionary: Keys are Strings (ids), values are Dictionaries
const ZONE_REGISTRY: Dictionary[String, Dictionary] = {
	"ruins": {
		"zone_name": "Ancient Ruins",
		"bgm": "res://audio/music/ruins_theme.ogg"
	},
	"caves": {
		"zone_name": "Forgotten Caves",
		"bgm": "res://audio/music/caves_theme.ogg"
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
		2: "01_a"
	},
	"01_b": {
		1: "01_a",
		2: "01_c"
	},
	"01_c": {
		1: "02_a",
		2: "01_b",
		3: "01_a"
	}
}
