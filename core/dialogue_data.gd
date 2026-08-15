
extends Node
const DATABASE = {
	"test_quest": [
		"Halt, traveler! The bridge is closed.",
		{
			"type": "quest_branch",
			"quest_id": "find_the_key",
			"branches": {
				"inactive": [
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
				"in_progress": [
					"Hurry up and find that key! It should be somewhere in the ruins."
				],
				"completed": [
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
	
	"test_intro": [
		"Hello traveler! Welcome to the ruins.",
		"This line plays after the choice branch finishes!"
	],
		"npc_1_initial": [
		"Hello traveler! Welcome to the ruins.",
		"Watch out round here!"
	],
		"npc_1_spoken": [
		"Hello again traveler!",
		"Good to see you again!"
	],
}
