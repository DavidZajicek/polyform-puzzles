class_name Polyforms
extends Resource

@export var polyominoes: Dictionary

var array: Array = []
var length: int = 1
var location: Vector2i = Vector2i.ZERO
var previous_location: Vector2i = Vector2i.ZERO
var steps: Array[Vector2i] = [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT]



func generate_shape(_size) -> void:
	
	var bitmap: BitMap = BitMap.new()
	bitmap.create(Vector2i(_size,_size))
	var permutations: int = _size * _size ** 2
	print(permutations)
	for x in _size:
		bitmap.set_bit(x, 0, true)
	polyominoes["bitmap"] = bitmap
	
	
	bitmap = rotate(bitmap)
	bitmap = flip(bitmap)
	
	bitmap = rotate(bitmap)
	
	
	polyominoes["bitmap flipped  rotated"] = array
	print("Saved flipped rotated")
	
	convert_bitmap_to_array(bitmap)
	
	ResourceSaver.save(self, resource_path)
	


func add_to_array(bitmap):
	var left_aligned_bitmap = align_shape_left(bitmap)
	var top_aligned_bitmap = align_shape_top(left_aligned_bitmap)
	var packed_array = convert_bitmap_to_array(top_aligned_bitmap)
	if packed_array not in array:
		array.append(packed_array)

###Works
func rotate(_bitmap: BitMap, _count: int = 4) -> BitMap:
	if _count <= 0:
		return _bitmap
	
	var _bitmap_rotated: BitMap = BitMap.new()
	var size: Vector2i = _bitmap.get_size()
	_bitmap_rotated.create(size)
	
	for x in size.x:
		for y in size.y:
			_bitmap_rotated.set_bit(size.y -y -1, x, _bitmap.get_bit(x, y))
	
	add_to_array(_bitmap_rotated)
	return rotate(_bitmap_rotated, _count - 1)

###Works
func flip(_bitmap: BitMap) -> BitMap:
	var _bitmap_flipped: BitMap = BitMap.new()
	var size: Vector2i = _bitmap.get_size()
	_bitmap_flipped.create(size)
	for x in size.x:
		for y in size.y:
			_bitmap_flipped.set_bit(size.x -x -1,size.y -y -1, _bitmap.get_bit(x, y))
	return _bitmap_flipped

###Works
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

func align_shape_left(_bitmap: BitMap) -> BitMap:
	var size: Vector2i = _bitmap.get_size()
	var _bitmap_shifted: BitMap = BitMap.new()
	_bitmap_shifted.create(size)
	for y in size.y:
		if _bitmap.get_bit(0, y):
			return _bitmap
	
	for x in size.x:
		for y in size.y:
			if _bitmap.get_bit(x, y):
				if _bitmap_shifted.get_bit(x-1, y) != null:
					_bitmap_shifted.set_bit(x-1, y, true)
	
	return align_shape_left(_bitmap_shifted)

func align_shape_top(_bitmap: BitMap) -> BitMap:
	var size: Vector2i = _bitmap.get_size()
	var _bitmap_shifted: BitMap = BitMap.new()
	_bitmap_shifted.create(size)
	for x in size.x:
		if _bitmap.get_bit(x, 0):
			return _bitmap
	
	for x in size.x:
		for y in size.y:
			if _bitmap.get_bit(x, y):
				if _bitmap_shifted.get_bit(x, y-1) != null:
					_bitmap_shifted.set_bit(x, y-1, true)
	
	return align_shape_top(_bitmap_shifted)


