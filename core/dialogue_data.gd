
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
					"Bring it to me and I'll let you through."
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


	"test_intro": [
		"Hello traveler! Welcome to the ruins.",
		{
			"text": "Do you wish to enter the dangerous zone?",
			"choices": ["Enter ruins", "Turn back"],
			# Define what happens next for each choice index [0] and [1]
			"branches": [
				["You bravely step past the gates...", "The air grows cold."], # Path for Choice 0
				["You turn around and walk away.", "Coward!"]                  # Path for Choice 1
			]
		},
		"This line plays after the choice branch finishes!"
	]
}
