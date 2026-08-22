extends Node

const DEFAULT_QUEST_STATES: Dictionary = {
	"find_the_key": "Inactive", 
	"defeat_boss": "Inactive",
	"find_the_boss": "Inactive",
	"defeat_dude": "Inactive",
	"death_quest": "Inactive"
}

func get_quest_state(quest_id: String) -> String:
	var slot = SaveManager.current_slot
	
	# Ensure the slot dictionary and quest_states container exist
	if SaveManager.SAVE_DATA.has(slot):
		if not SaveManager.SAVE_DATA[slot].has("quest_states"):
			SaveManager.SAVE_DATA[slot]["quest_states"] = DEFAULT_QUEST_STATES.duplicate(true)
		return SaveManager.SAVE_DATA[slot]["quest_states"].get(quest_id, "Inactive")
		
	return "Inactive"
	
func set_quest_state(quest_id: String, state: String) -> void:
	var slot = SaveManager.current_slot
	
	if not SaveManager.SAVE_DATA.has(slot):
		SaveManager.SAVE_DATA[slot] = {}
		
	if not SaveManager.SAVE_DATA[slot].has("quest_states"):
		SaveManager.SAVE_DATA[slot]["quest_states"] = DEFAULT_QUEST_STATES.duplicate(true)
		
	if SaveManager.SAVE_DATA[slot]["quest_states"].has(quest_id):
		SaveManager.SAVE_DATA[slot]["quest_states"][quest_id] = state
		print("Quest Updated for Slot %s: %s -> %s" % [slot, quest_id, state])

		# Instantly write the active slot data to disk
		SaveManager.save_to_disk()
