extends Node

# Checks if the games vibration feature is toggled on before running
# so it can be called in one line anywhere
func run(duration: int) -> void:
	if not SaveManager.SETTINGS_DATA["Vibration"]:
		return

	Input.vibrate_handheld(duration)
	print("vibrating!!!")
