class_name PolyBitMap
extends BitMap

#var inner_walls: PackedVector2Array : get = get_all_inner_walls

var orthogonally_adjacent_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]

func get_all_inner_walls(must_be_connected_orthogonally: bool = true) -> PackedVector2Array:
	var points: PackedVector2Array = []
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


func get_all_outer_walls(walls: PackedVector2Array) -> PackedVector2Array:
	var adjacent_empty_spaces: PackedVector2Array = []
	for wall in walls:
		for direction in orthogonally_adjacent_directions:
			var point_to_test: Vector2i = (direction + Vector2i(wall)).clamp(Vector2i.ZERO, get_size() - Vector2i(1, 1))
			if adjacent_empty_spaces.find(point_to_test) < 1 and not get_bitv(point_to_test):
				adjacent_empty_spaces.append(point_to_test)
	
	return adjacent_empty_spaces

func get_all_outer_edges(walls: PackedVector2Array) -> PackedVector2Array:
	var adjacent_empty_spaces: PackedVector2Array = []
	for wall in walls:
		for direction in orthogonally_adjacent_directions:
			var point_to_test: Vector2i = (direction + Vector2i(wall))
			if adjacent_empty_spaces.find(point_to_test) > 0:
				continue
			if (
					point_to_test.x < 0
					or point_to_test.x > get_size().x - 1
					or point_to_test.y < 0
					or point_to_test.y > get_size().y - 1
			):
				adjacent_empty_spaces.append(point_to_test)
				continue
			if not get_bitv(point_to_test):
				adjacent_empty_spaces.append(point_to_test)
	
	return adjacent_empty_spaces

func get_all_columns() -> Array[PackedVector2Array]:
	var columns: Array[PackedVector2Array] = []
	var y_points: PackedVector2Array = []
	
	for x in get_size().x:
		for y in get_size().y:
			if get_bit(x, y):
				var location: Vector2i = Vector2i(x, y)
				y_points.append(location)
		if y_points.size() == get_size().y:
			columns.append(y_points.duplicate())
		y_points.clear()
	return columns
	

func get_all_rows() -> Array[PackedVector2Array]:
	var rows: Array[PackedVector2Array] = []
	var x_points: PackedVector2Array = []
	
	for y in get_size().x:
		for x in get_size().y:
			if get_bit(x, y):
				var location: Vector2i = Vector2i(x, y)
				x_points.append(location)
		if x_points.size() == get_size().y:
			rows.append(x_points.duplicate())
		x_points.clear()
	return rows

func get_all_lines() -> PackedVector2Array:
	var columns: Array[PackedVector2Array] = get_all_columns()
	var rows: Array[PackedVector2Array] = get_all_rows()
	var points: PackedVector2Array = []
	for row in rows:
		for point in row:
			if point not in points:
				points.append(point)
	
	for column in columns:
		for point in column:
			if point not in points:
				points.append(point)
	
	return points

func get_total_line_count():
	var columns: Array[PackedVector2Array] = get_all_columns()
	var rows: Array[PackedVector2Array] = get_all_rows()
	return columns.size() + rows.size()



