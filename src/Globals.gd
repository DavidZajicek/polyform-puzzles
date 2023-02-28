extends Node

@export var tile_size: Vector2 = Vector2(64, 64)
@export var poly_size: int = 6

var top_score: Scores

func _ready() -> void:
	_create_or_load_save()

func _create_or_load_save():
	if Scores.save_exists():
		Globals.top_score = ResourceLoader.load("user://topscore.tres","",ResourceLoader.CACHE_MODE_IGNORE)
	else:
		Globals.top_score = Scores.new()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		top_score.write_savegame()
