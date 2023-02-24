class_name Scores
extends Resource

@export var top_score: int = 0 : set = set_score#, get = get_score



func set_score(new_score: int):
	top_score = new_score
	ResourceSaver.save(Scores, "user://topscore.tres")
#
#func get_score() -> int:
#	return top_score
