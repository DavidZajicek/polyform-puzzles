class_name Poly
extends Area2D

var score: int = 1
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal destroy_poly

#func _physics_process(_delta: float) -> void:
#	drop_shadow.position = snapped(position, Globals.tile_size)

func destroy():
	queue_free()

