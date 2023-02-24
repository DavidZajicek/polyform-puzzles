class_name Poly
extends Area2D

var score: int = 1
@onready var label: Label = $Label

signal destroy_poly

#func _physics_process(_delta: float) -> void:
#	label.text = str(global_position)

func destroy():
	emit_signal("destroy_poly", score)
