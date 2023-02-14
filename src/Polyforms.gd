class_name Polyforms
extends Resource

@export var polyominoes: Dictionary

var array: Array = [[]]
var length: int = 1
var location: Vector2i = Vector2i.ZERO
var previous_location: Vector2i = Vector2i.ZERO
var steps: Array[Vector2i] = [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT]



func generate_shape(_size) -> void:
	print(location)
	array.resize(_size)
	array.fill([])
	for y in _size:
		array[y].resize(_size)
		array[y].fill(0)
	print(array)
	for size in _size -1:
		for step in steps:
			if step + location == previous_location:
				print("walking backwards")
				continue
			var next_location: Vector2i = location + step
			next_location = next_location.clamp(Vector2i.ZERO, Vector2i(_size, _size))
			if array[next_location.y][next_location.x] == 1:
				print("moving right along, footloose and fancy free")
				continue
			for bit in range(2):
				array[next_location.y][next_location.x] = bit
				if bit == 1:
					previous_location = location
					next_location = location
					print(array)
	
	
	
#	array.resize(_size)
#	for y in _size:
#		array[y].resize(_size)
#		for x in _size:
#			if length == _size:
#				test(array)
#				return
#			if array[y][x] == null:
#				for dir in steps:
#					match dir:
#						0:
#							pass
#				for bit in range(2):
#					array[y][x] = bit
#
#					if bit == 1:
#						length += 1
#						previous_location = Vector2i(x, y)
#						print(array)
	
#	var new_array = rotate(array)
func test(array):
	if array not in polyominoes:
		polyominoes["bitmap"] = array
		save_shape()
	
	

	print("tested")
	return

func rotate(_array, _count):
	
	print("rotated")
	return array

func save_shape() -> void:
	ResourceSaver.save(self, resource_path)

func check_rotations_in_dictionary(shape: Array[PackedVector2Array], count: int) -> void:
	pass
