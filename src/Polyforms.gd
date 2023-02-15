class_name Polyforms
extends Resource

@export var polyominoes: Dictionary

var array: Array = [[]]
var length: int = 1
var location: Vector2i = Vector2i.ZERO
var previous_location: Vector2i = Vector2i.ZERO
var steps: Array[Vector2i] = [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT]



func generate_shape(_size) -> void:
	
	var bitmap: BitMap = BitMap.new()
	bitmap.create(Vector2i(_size,_size))
	for x in _size:
		bitmap.set_bit(x, 0, true)
	print(bitmap, "steve")
	polyominoes["bitmap"] = bitmap
	
	var bitmap_array: Array[BitMap]
	
	for turns in range(4):
		bitmap = rotate(bitmap)
		bitmap_array.append_array(convert_bitmap_to_array(bitmap))
		print(bitmap, "rotation", turns)
	bitmap = flip(bitmap)
	
	print(bitmap, "flip")
	
	for turns in range(4):
		bitmap = rotate(bitmap)
		bitmap_array.append_array(convert_bitmap_to_array(bitmap))
		print(bitmap, "rotation", turns, "flipped")
	
	
	polyominoes["bitmap flipped  rotated"] = bitmap_array
	print("Saved flipped rotated")
	
	convert_bitmap_to_array(bitmap)
	
	ResourceSaver.save(self, resource_path)
	


func test(array):
	if array not in polyominoes:
		polyominoes["bitmap"] = array
		save_shape()
	
	
	print("tested")
	return

###Works
func rotate(_bitmap: BitMap) -> BitMap:
	var _bitmap_rotated: BitMap = BitMap.new()
	var size: Vector2i = _bitmap.get_size()
	_bitmap_rotated.create(size)
	for x in size.x:
		for y in size.y:
			_bitmap_rotated.set_bit(size.y -y -1, x, _bitmap.get_bit(x, y))
	
	return _bitmap_rotated

###Works
func flip(_bitmap: BitMap) -> BitMap:
	var _bitmap_flipped: BitMap = BitMap.new()
	var size: Vector2i = _bitmap.get_size()
	_bitmap_flipped.create(size)
	for x in size.x:
		for y in size.y:
			_bitmap_flipped.set_bit(size.x -x -1,size.y -y -1, _bitmap.get_bit(x, y))
	return _bitmap_flipped

func convert_bitmap_to_array(bitmap: BitMap) -> PackedVector2Array:
	var packed_vector_array: PackedVector2Array
	var size: Vector2i = bitmap.get_size()
	for x in size.x:
		for y in size.y:
			if bitmap.get_bit(x, y):
				packed_vector_array.append(Vector2i(x, y))
	return packed_vector_array

func save_shape() -> void:
	ResourceSaver.save(self, resource_path)

func check_rotations_in_dictionary(shape: Array[PackedVector2Array], count: int) -> void:
	pass
