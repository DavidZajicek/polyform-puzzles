extends Node2D

#constants

#exports
@export var grid_size: Vector2 = Vector2(6, 6)

#onready
@onready var grid_tile: PackedScene = preload("res://GridTile.tscn")
@onready var bitmap: PolyBitMap = PolyBitMap.new()
@onready var rect: Rect2i = Rect2i(Vector2i.ZERO, grid_size * Globals.tile_size)

#vars

# Called when the node enters the scene tree for the first time.
func _ready():
	bitmap.create(grid_size)
	create_grid()



func create_grid() -> void:
	for x in grid_size.x:
		for y in grid_size.y:
			var new_tile = grid_tile.instantiate()
			add_child(new_tile)
			
			new_tile.position = Vector2(x, y) * Globals.tile_size

func destroy_lines():
	var points = bitmap.get_all_lines()
	for child in get_children():
		if child is Poly:
			for point in points:
				if child.position / Globals.tile_size == point:
					child.queue_free()
					bitmap.set_bitv(point, false)
