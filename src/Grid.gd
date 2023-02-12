extends CanvasGroup

#constants

#exports

#onready
@onready var grid_tile: PackedScene = preload("res://GridTile.tscn")

#vars
var grid_size: Vector2 = Vector2(6, 6)
var grid_array: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	create_grid()
	#print(grid_array)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func create_grid() -> void:
	for x in grid_size.x:
		grid_array.append([])
		for y in grid_size.y:
			var new_tile = grid_tile.instantiate()
			add_child(new_tile)
			
			new_tile.position = Vector2(x, y) * Globals.tile_size
			grid_array[x].append("{x}, {y}".format({"x": x, "y": y}))
