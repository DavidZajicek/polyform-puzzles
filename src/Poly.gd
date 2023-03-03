class_name Poly
extends Area2D

var score: int = 1
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D


signal destroy_poly

func _ready() -> void:
	sprite_2d.texture = Globals.user_settings.block_texture
#func _physics_process(_delta: float) -> void:
#	drop_shadow.position = snapped(position, Globals.tile_size)

func destroy():
	queue_free()

