class_name Grid
extends Node2D

#constants

#exports
@export var grid_size: Vector2 = Vector2(6, 6)

#onready
@onready var grid_tile: PackedScene = preload("res://GridTile.tscn")
@onready var bitmap: PolyBitMap = PolyBitMap.new()
@onready var rect: Rect2i = Rect2i(Vector2i.ZERO, grid_size)

#vars

# Called when the node enters the scene tree for the first time.
func _ready():
	bitmap.create(grid_size)
	create_grid()

func _process(_delta: float) -> void:
	bitmap.opaque_to_polygons(rect)


func create_grid() -> void:
	for x in grid_size.x:
		for y in grid_size.y:
			var new_tile = grid_tile.instantiate()
			add_child(new_tile)
			
			new_tile.position = Vector2(x, y) * Globals.tile_size
			new_tile.modulate = Globals.user_settings.grid_tile_colour

func destroy_lines():
	var points = bitmap.get_all_lines()
	var total_rows: int = bitmap.get_all_rows().size() + 1
	var total_columns: int = bitmap.get_all_columns().size() + 1
	var multiplier: int = total_columns * total_rows
	for child in get_children():
		if child is Poly:
			for point in points:
				if child.position / Globals.tile_size == point:
					child.emit_signal("destroy_poly", child.score * multiplier)
					child.animation_player.play("destroy")
					bitmap.set_bitv(point, false)

