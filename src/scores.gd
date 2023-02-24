class_name Scores # Bug in Godot
extends Resource

const SAVE_GAME_BASE_PATH := "user://topscore"

@export var top_score: int = 0 : set = set_score, get = get_score



func set_score(new_score: int):
	top_score = new_score
	write_savegame()

func get_score() -> int:
	return top_score

func write_savegame() -> void:
	ResourceSaver.save(self, get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())

static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension

