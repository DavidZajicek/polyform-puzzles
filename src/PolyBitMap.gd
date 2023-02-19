class_name PolyBitMap
extends BitMap

#var inner_walls: PackedVector2Array : get = get_all_inner_walls

var orthogonally_adjacent_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]

func get_all_inner_walls(must_be_connected_orthogonally: bool = true) -> PackedVector2Array:
	var points: PackedVector2Array
	for x in get_size().x:
		for y in get_size().y:
			if get_bit(x, y):
				var location: Vector2i = Vector2i(x, y)
				points.append(location)
				if must_be_connected_orthogonally and not points.find(location):
					points = get_adjacent_walls(location)
	return points

func get_adjacent_walls(starting_location: Vector2i) -> PackedVector2Array:
	var location: Vector2i = starting_location
	var adjacent_walls: PackedVector2Array = [starting_location]
	for step in get_size():
		for direction in orthogonally_adjacent_directions:
			var point_to_test: Vector2i = (direction + Vector2i(location)).clamp(Vector2i.ZERO, get_size() - Vector2i(1, 1))
			if not adjacent_walls.find(point_to_test) and get_bitv(point_to_test):
				adjacent_walls.append(point_to_test)
	return adjacent_walls

func if_touching_adjacent(starting_location: Vector2i):
	pass

func get_all_outer_walls(walls: PackedVector2Array) -> PackedVector2Array:
	var adjacent_empty_spaces: PackedVector2Array
	for wall in walls:
		for direction in orthogonally_adjacent_directions:
			var point_to_test: Vector2i = (direction + Vector2i(wall)).clamp(Vector2i.ZERO, get_size() - Vector2i(1, 1))
			if adjacent_empty_spaces.find(point_to_test) < 1 and not get_bitv(point_to_test):
				adjacent_empty_spaces.append(point_to_test)
	
	return adjacent_empty_spaces
