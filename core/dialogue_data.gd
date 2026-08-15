
extends Node

const DIALOGUE_DATA: Dictionary[String, Dictionary] = {
	"English":
		{"Tutorials":
			{"Drop through platforms":"Swipe down to drop through platforms",
			"Jump":"Press A to jump",
			"Attack":"Press B to attack"}
		},
	"Polish":
		{"Tutorials":
			{"Drop through platforms":"Swipe down to drop through platforms",
			"Jump":"Press A to jump",
			"Attack":"Press B to attack"}
		}
}

const DATABASE = {
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
