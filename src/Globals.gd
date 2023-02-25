extends Node

@export var tile_size: Vector2 = Vector2(64, 64)
@export var poly_size: int = 6

@onready var top_score: Scores

func _ready() -> void:
	_create_or_load_save()

func _create_or_load_save():
	if Scores.save_exists():
		Globals.top_score = load("user://topscore.tres")
	else:
		Globals.top_score = Scores.new()
