class_name Polyforms
extends Resource

@export var polyominoes: Dictionary
@export var free_polyominoes: Dictionary


var length: int = 1
var previous_location: Vector2i = Vector2i.ZERO
var location: Vector2i = Vector2i.ZERO
var steps: Array[Vector2i] = [Vector2i.ZERO, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT]
var size: int = 0
var first_index_allow_empty: bool = true


var _rotated_bitmap_array: Array[BitMap]

func generate_shape(_size) -> void:
	#TODO: extract into a "setup" method
	if _size == 0:
		return
	size = _size
	
	_rotated_bitmap_array.clear()
	first_index_allow_empty = true
	
	var bitmap: BitMap = BitMap.new()
	bitmap.create(Vector2i(size,size))
	location = Vector2i(Vector2(size, size).clamp(Vector2.ZERO, Vector2i(size, size)) / 2)
	var _permutations: int = size * size ** 2
	var iteration: int
	var bitmap_array: Array[BitMap] = [bitmap]
	
	var time = Time.get_unix_time_from_system()
	
	var broken_dicktionary: Dictionary
	broken_dicktionary[location] = bitmap
	for i in range(size * size):
		broken_dicktionary = paint(bitmap_array)
	
	free_polyominoes = broken_dicktionary
	
	print(Time.get_time_string_from_unix_time(Time.get_unix_time_from_system() - time)  )
#
#
#	var dict: Dictionary = {"next_bitmaps": [bitmap], "location": Vector2i.ZERO}
#	var array = walk(dict, size)
#
#
#	for _bitmap in array:
#		var aligned_bitmap = align_shape(_bitmap)
#		rotate(aligned_bitmap)
#		if _rotated_bitmap_array.any(func(_bitmap): return _bitmap in polyominoes.values()):
#			_rotated_bitmap_array.clear()
#		else:
#			add_to_array(aligned_bitmap, str(aligned_bitmap))
#
#
#
#
#
	ResourceSaver.save(self, resource_path)
	

func paint(bitmap_array: Array[BitMap]):
	var temp_dictionary: Dictionary
	for bitmap in bitmap_array:
		var first_steps: = check_next_steps(bitmap, location)
		for step in first_steps:
			var next_step_bitmap: BitMap = bitmap.duplicate()
			if next_step_bitmap.get_true_bit_count() == size:
				temp_dictionary[str(size) + "_" + str(size)] = [next_step_bitmap]
				add_to_array(next_step_bitmap)
			elif next_step_bitmap.get_true_bit_count() < size:
				temp_dictionary[step] = next_step_bitmap
			
			for _step in first_steps:
				var second_step_bitmap: BitMap = next_step_bitmap.duplicate()
				second_step_bitmap.set_bitv(_step, true)
				if second_step_bitmap.get_true_bit_count() == size:
					temp_dictionary[str(size) + "_" + str(size) + "_" + str(_step)] = [second_step_bitmap]
					add_to_array(second_step_bitmap)
				elif second_step_bitmap.get_true_bit_count() < size:
					temp_dictionary[_step] = second_step_bitmap
	location = steps[randi() % steps.size()]
	return temp_dictionary.duplicate()
	


func walk(bitmap_dictionary: Dictionary, count):
	if count <= 0:
		var final_array: Array[BitMap] = []
		for bitmap in bitmap_dictionary["next_bitmaps"]:
			if bitmap.get_true_bit_count() == size:
				print("size matches size")
				final_array.append(bitmap)
		return final_array
	var _location: Vector2i = bitmap_dictionary["location"]
	var _next_bitmap_dictionary: Dictionary = bitmap_dictionary
	
	for _bitmap in bitmap_dictionary["next_bitmaps"]:
		var _next_steps: Array[Vector2i] = check_next_steps(_bitmap, _location)
		var _next_bitmap_dictionary_to_merge = paint_next_steps(_bitmap, _next_steps, _location)
		if _next_bitmap_dictionary_to_merge.is_empty():
			continue
		_next_bitmap_dictionary["next_bitmaps"] += _next_bitmap_dictionary_to_merge["next_bitmaps"]
		_next_bitmap_dictionary["location"] = _next_bitmap_dictionary_to_merge["location"]
	
	return walk(_next_bitmap_dictionary, count - 1)



func check_next_steps(_bitmap: BitMap, _location: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	var unpainted_bits: Array[Vector2i] = []
	for step in steps:
		var next_step = (_location + step).clamp(Vector2i.ZERO, Vector2i(size-1, size-1))
		if not _bitmap.get_bitv(next_step) and next_step not in unpainted_bits:
			unpainted_bits.append(next_step)
	if not first_index_allow_empty:
		for step in unpainted_bits:
			unpainted_bits.erase(Vector2i.ZERO)
	
	return unpainted_bits


func paint_next_steps(_bitmap: BitMap, _next_steps: Array[Vector2i], _location: Vector2i) -> Dictionary:
	var next_bitmaps: Array[BitMap] = []
	var bitmaps_and_location: Dictionary = {}
	var potential_next_locations: Array[Vector2i]
	if not _bitmap.get_bitv(_location) and not first_index_allow_empty:
		return bitmaps_and_location
	
	for _next_step in _next_steps:
		var next_bitmap: BitMap = _bitmap.duplicate()
		next_bitmap.set_bitv(_next_step, true)
		next_bitmaps.append(next_bitmap)
		potential_next_locations.append(_next_step)
	
	bitmaps_and_location["next_bitmaps"] = next_bitmaps
	for location in potential_next_locations:
		potential_next_locations.erase(Vector2i.ZERO)
	first_index_allow_empty = false
	bitmaps_and_location["location"] = potential_next_locations[randi() % potential_next_locations.size()]
	return bitmaps_and_location


func add_to_array(_bitmap: BitMap):
	if _bitmap.get_true_bit_count() == 0:
		print("Cannot add an empty BitMap to Dictionary")
		return
	var packed_array = convert_bitmap_to_array(_bitmap)
	var block_name: String = str(size) + "_" + str(packed_array)
	polyominoes[block_name] = packed_array

###Works
func rotate(_bitmap: BitMap, _count: int = 4) -> BitMap:
	if _count <= 0:
		return _bitmap
	var _bitmap_rotated: BitMap = BitMap.new()
	_bitmap_rotated.create(Vector2i(size, size))
	
	for x in size:
		for y in size:
			_bitmap_rotated.set_bit(size -y -1, x, _bitmap.get_bit(x, y))
	
	_rotated_bitmap_array.append(_bitmap_rotated)
	
	return rotate(_bitmap_rotated, _count - 1)

###Works
func flip(_bitmap: BitMap) -> BitMap:
	var _bitmap_flipped: BitMap = BitMap.new()
	_bitmap_flipped.create(Vector2i(size, size))
	for x in size:
		for y in size:
			_bitmap_flipped.set_bit(size -x -1,size -y -1, _bitmap.get_bit(x, y))
	return _bitmap_flipped

###Works
func convert_bitmap_to_array(_bitmap: BitMap) -> PackedVector2Array:
	var _packed_vector_array: PackedVector2Array = []
	for x in size:
		for y in size:
			if _bitmap.get_bit(x, y):
				_packed_vector_array.append(Vector2i(x, y))
	return _packed_vector_array

func align_shape(_bitmap: BitMap) -> BitMap:
		var left_aligned_bitmap = align_shape_left(_bitmap)
		return align_shape_top(left_aligned_bitmap)

func align_shape_left(_bitmap: BitMap) -> BitMap:
	var _bitmap_shifted: BitMap = BitMap.new()
	_bitmap_shifted.create(Vector2i(size, size))
	for y in size:
		if _bitmap.get_bit(0, y):
			return _bitmap
	
	for x in size:
		for y in size:
			if _bitmap.get_bit(x, y):
				if _bitmap_shifted.get_bit(x-1, y) != null:
					_bitmap_shifted.set_bit(x-1, y, true)
	
	return align_shape_left(_bitmap_shifted)

func align_shape_top(_bitmap: BitMap) -> BitMap:
	var _bitmap_shifted: BitMap = BitMap.new()
	_bitmap_shifted.create(Vector2i(size, size))
	for x in size:
		if _bitmap.get_bit(x, 0):
			return _bitmap
	
	for x in size:
		for y in size:
			if _bitmap.get_bit(x, y):
				if _bitmap_shifted.get_bit(x, y-1) != null:
					_bitmap_shifted.set_bit(x, y-1, true)
	
	return align_shape_top(_bitmap_shifted)


