extends Node

enum GameState { SPLASH, TITLE, CINEMATIC, WORLD }

const SCENES: Dictionary[GameState, String] = {
	GameState.SPLASH: "res://states/splash_state/splash_state.tscn",
	GameState.TITLE: "res://states/title_state/title_state.tscn",
	GameState.CINEMATIC: "res://states/cinematic_state/cinematic_state.tscn",
	GameState.WORLD: "res://states/world_state/world_state.tscn"
}

func change_state(target_state: GameState,\
in_duration: float = 0.2,\
out_duration: float = 0.6,\
in_mode: String = "fade",\
out_mode: String = "fade"):
	
	TransitionManager.transition(func():
		var target_path = SCENES[target_state]
		get_tree().change_scene_to_file(target_path),
		in_duration,
		out_duration,
		in_mode,
		out_mode
	)
