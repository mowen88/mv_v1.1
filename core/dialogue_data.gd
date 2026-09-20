
extends Node

const ABILITY_DETAILS: Dictionary = {
	"Beam Blade": "A focused beam of energy that slices through obstacles. Hold A button to use.",
	"Glide": "Allows you to glide smoothly through the air over long gaps. Hold B button while falling to use.",
	"Jump Attack": "Perform a powerful downward strike while airborne. Swipe up while on the ground to use.",
	"Water Walk": "Enables movement safely across the surface of water",
	"Ground Slam": "Dive into the ground to break weak floors and damage nearby enemies. Swipe down while in the air to use."
}

const ITEM_DETAILS: Dictionary = {
	"Key cube": "A cube-shaped key used to open gates that require varying quantities to unlock.",
	"Ruby": "A radiant red gemstone that pulses with a faint internal warmth.",
	"Stone": "A dense piece of carved masonry.",
	"Tablet": "Inscribed with ancient text detailing forgotten lore.",
	"Hanky": "A delicate piece of cloth embroidered with a faded crest.",
	"Rope": "A strong coil of braided fiber, roughly ten meters long.",
	"Candle": "A thick wax candle that provides a small radius of warm light."
}


const DATABASE = {
	"test_quest": [
		"Halt, traveler! The bridge is closed.",
		{
			"type": "quest_branch",
			"quest_id": "find_the_key",
			"branches": {
				"Inactive": [
					"If you want to pass, you'll need to find the old gate key.",
					{
						"text": "Will you help me find it?",
						"choices": ["Accept Quest", "Decline"],
						"branches": [
							[
								"Thank you! Seek it within the ruins."
							],
							[
								"Come back if you change your mind."
							]
						]
					}
				],
				"In progress": [
					"Hurry up and find that key! It should be somewhere in the ruins."
				],
				"Completed": [
					"Ah, you got the key! Go right on through."
				]
			}
		}
	],

	"test_choices": [
		"Hello traveler! Welcome to the ruins.",
		{
			"text": "Do you wish to enter the dangerous zone?",
			"choices": ["Enter ruins", "Turn back"],
			"branches": [
				["You bravely step past the gates...", "The air grows cold."],
				["You turn around and walk away.", "Coward!"]
			]
		},
		"This line plays after the choice branch finishes!"
	],
	
	#"test_intro": [
		#"Hello traveler! Welcome to the ruins.",
		#"This line plays after the choice branch finishes!"
	#],
		#"npc_1_initial": [
		#"Hello traveler! Welcome to the ruins.",
		#"Watch out round here!"
	#],
		#"npc_1_spoken": [
		#"Hello again traveler!",
		#"Good to see you again!"
	#],
	
	"npc_1_initial": [
		"Hello traveller, carry on holding attack to trigger a great beam attack"
	],
	
	"npc_1_spoken": [
		"Hello again, have you tried your beam attack yet? Powerful it is!"
	],
}
