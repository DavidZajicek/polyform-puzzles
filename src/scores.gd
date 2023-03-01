class_name Scores # Bug in Godot
extends Resource

const SAVE_GAME_BASE_PATH := "user://topscore"

@export var version: int = 2
@export var top_score: int = 0
@export var top_scores: Dictionary
#move into settings save
@export var background_colour: Color = Color(0.3, 0.3, 0.3, 1.0) : set = set_background_colour
@export var grid_tile_colour: Color = Color(0.0, 0.0, 1.0, 0.5) : set = set_grid_tile_colour



func set_score(new_score: int):
	top_score = new_score
	write_savegame()

func get_score() -> int:
	var _top_score: int
	for score in top_scores.values():
		if score > _top_score:
			_top_score = score
	return _top_score

func set_scores(new_score: int):
	if not top_scores.has(Globals.poly_size):
		top_scores[Globals.poly_size] = new_score
	else:
		if new_score > top_scores[Globals.poly_size]:
			top_scores[Globals.poly_size] = new_score
			top_score = get_score()
	write_savegame()


func write_savegame() -> void:
	ResourceSaver.save(self, get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())

static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension

func set_background_colour(colour):
	background_colour = colour
	write_savegame()

func set_grid_tile_colour(colour):
	grid_tile_colour = colour
	write_savegame()
