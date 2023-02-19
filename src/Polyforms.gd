class_name Polyforms
extends Resource

@export var polyominoes: Dictionary
@export var free_polyominoes: Dictionary
@export var unfinished_polyominoes: Dictionary


var length: int = 1
var previous_location: Vector2i = Vector2i.ZERO
var location: Vector2i = Vector2i.ZERO
var steps: Array[Vector2i] = [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.ZERO]
var size: int = 0
var first_index_allow_empty: bool = true

var fixed_index: int = 0
var free_index: int = 0
var iteration: int = 0

var _rotated_PolyBitMap_array: Array[PolyBitMap]

func generate_shape(_size) -> void:
	#TODO: extract into a "setup" method
	if _size == 0:
		return
	size = _size
	
	_rotated_PolyBitMap_array.clear()
	first_index_allow_empty = true
	
	var polyBitMap: PolyBitMap = PolyBitMap.new()
	polyBitMap.create(Vector2i(size,size))
	polyBitMap.set_bitv(Vector2i(Vector2(size, size).clamp(Vector2.ZERO, Vector2i(size, size)) / 2), true)
	var _permutations: int = size * size ** 2
	var polyBitMap_array: Array[PolyBitMap] = [polyBitMap]
	
	var time = Time.get_unix_time_from_system()
	
	
	var broken_dicktionary: Dictionary
	broken_dicktionary[location] = [polyBitMap]
	for i in range(size):
		broken_dicktionary = paint(broken_dicktionary)
	
	print(iteration)
	print(Time.get_time_string_from_unix_time(Time.get_unix_time_from_system() - time)  )
	
	
	ResourceSaver.save(self, resource_path)
	

func paint(broken_dicktionary: Dictionary):
	var temp_dictionary: Dictionary
	for _location in broken_dicktionary:
		for polyBitMap in broken_dicktionary[_location]:
			var walls: PackedVector2Array = polyBitMap.get_all_inner_walls()
			var next_steps: PackedVector2Array = polyBitMap.get_all_outer_walls(walls)
			
			for i in next_steps.size():
				var _polyBitMap: PolyBitMap = polyBitMap.duplicate()
				for step in next_steps:
					var next_step_PolyBitMap: PolyBitMap = _polyBitMap.duplicate()
					if touching_another_painted_space(next_step_PolyBitMap, step) or first_index_allow_empty:
						next_step_PolyBitMap.set_bitv(step, true)
					if next_step_PolyBitMap.get_true_bit_count() == size:
						add_to_array(next_step_PolyBitMap)
					elif next_step_PolyBitMap.get_true_bit_count() < size:
						temp_dictionary[str(step) + str(i)] = [next_step_PolyBitMap] #This overwrites, not adds so we aren't building every permutation
						
					iteration += 1
			
			first_index_allow_empty = false
	return temp_dictionary.duplicate()
	

func touching_another_painted_space(_PolyBitMap: PolyBitMap, _location: Vector2i = Vector2i.ZERO) -> bool:
	var adjacent_tiles: bool = false
	for step in steps:
		if _PolyBitMap.get_bitv((_location + step).clamp(Vector2i.ZERO, Vector2i(size-1, size-1))):
			adjacent_tiles = true
	return adjacent_tiles


func check_next_steps(_polyBitMap: PolyBitMap, _location: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	var unpainted_bits: Array[Vector2i] = []
	for step in steps:
		var next_step = (_location + step).clamp(Vector2i.ZERO, Vector2i(size-1, size-1))
		if not _polyBitMap.get_bitv(next_step) and next_step not in unpainted_bits:
			unpainted_bits.append(next_step)
	if not first_index_allow_empty:
		for step in unpainted_bits:
			unpainted_bits.erase(Vector2i.ZERO)
	
	return unpainted_bits



func add_to_array(_polyBitMap: PolyBitMap):
	if _polyBitMap.get_true_bit_count() == 0:
		print("Cannot add an empty PolyBitMap to Dictionary")
		return
	var rotated_PolyBitMaps: Array[PolyBitMap] = rotate(_polyBitMap)
	var fixed_PolyBitMaps: Array[PolyBitMap] = rotated_PolyBitMaps.duplicate()
	for PolyBitMap in rotated_PolyBitMaps:
		fixed_PolyBitMaps.append(flip(PolyBitMap))
	for fixed_PolyBitMap in fixed_PolyBitMaps:
		var packed_array = convert_PolyBitMap_to_array(fixed_PolyBitMap)
		if not packed_array in free_polyominoes.values():
			var block_name: String = str(size) + "_" + str(packed_array)
			free_polyominoes[block_name] = packed_array
			if free_polyominoes.values().find(packed_array) != 0 and polyominoes.values().find(packed_array) == 0:
				polyominoes[block_name] = packed_array

###Works
func rotate(_PolyBitMap: PolyBitMap, rotations: int = 4) -> Array[PolyBitMap]:
	var rotated_PolyBitMaps: Array[PolyBitMap]
	var _new_PolyBitMap: PolyBitMap = _PolyBitMap.duplicate()
	for rotation in rotations:
		var _polyBitMap_rotated: PolyBitMap = PolyBitMap.new()
		_polyBitMap_rotated.create(Vector2i(size, size))
		for x in size:
			for y in size:
				_polyBitMap_rotated.set_bit(size -y -1, x, _new_PolyBitMap.get_bit(x, y))
		var aligned_PolyBitMap = align_shape(_polyBitMap_rotated)
		rotated_PolyBitMaps.append(aligned_PolyBitMap)
		_new_PolyBitMap = aligned_PolyBitMap
	
	return rotated_PolyBitMaps

###Works
func flip(_polyBitMap: PolyBitMap) -> PolyBitMap:
	var _polyBitMap_flipped: PolyBitMap = PolyBitMap.new()
	_polyBitMap_flipped.create(Vector2i(size, size))
	for x in size:
		for y in size:
			_polyBitMap_flipped.set_bit(size -x -1, y, _polyBitMap.get_bit(x, y))
	return align_shape(_polyBitMap_flipped)

###Works
func convert_PolyBitMap_to_array(_PolyBitMap: PolyBitMap) -> PackedVector2Array:
	var _packed_vector_array: PackedVector2Array = []
	for x in size:
		for y in size:
			if _PolyBitMap.get_bit(x, y):
				_packed_vector_array.append(Vector2i(x, y))
	return _packed_vector_array

func align_shape(_PolyBitMap: PolyBitMap) -> PolyBitMap:
	var left_aligned_PolyBitMap = align_shape_left(_PolyBitMap)
	var top_aligned_PolyBitMap = align_shape_top(left_aligned_PolyBitMap)
	return top_aligned_PolyBitMap

func align_shape_left(_polyBitMap: PolyBitMap) -> PolyBitMap:
	var _polyBitMap_shifted: PolyBitMap = PolyBitMap.new()
	_polyBitMap_shifted.create(Vector2i(size, size))
	for y in size:
		if _polyBitMap.get_bit(0, y):
			return _polyBitMap
	
	for x in size:
		for y in size:
			if _polyBitMap.get_bit(x, y):
				if _polyBitMap_shifted.get_bit(x-1, y) != null:
					_polyBitMap_shifted.set_bit(x-1, y, true)
	
	return align_shape_left(_polyBitMap_shifted)

func align_shape_top(_polyBitMap: PolyBitMap) -> PolyBitMap:
	var _polyBitMap_shifted: PolyBitMap = PolyBitMap.new()
	_polyBitMap_shifted.create(Vector2i(size, size))
	for x in size:
		if _polyBitMap.get_bit(x, 0):
			return _polyBitMap
	
	for x in size:
		for y in size:
			if _polyBitMap.get_bit(x, y):
				if _polyBitMap_shifted.get_bit(x, y-1) != null:
					_polyBitMap_shifted.set_bit(x, y-1, true)
	
	return align_shape_top(_polyBitMap_shifted)


