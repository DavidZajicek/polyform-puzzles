class_name Polyforms
extends Resource

@export var polyominoes: Dictionary
@export var free_polyominoes: Dictionary
@export var unfinished: Dictionary
@export var polyomino_details: Dictionary = {}

var location: Vector2i = Vector2i.ZERO
var size: int = 0

var iteration: int = 0


func generate_shape(_size) -> void:
	#TODO: extract into a "setup" method
	if _size == 0:
		return
	size = _size
	
	#TODO: REMOVE THESE OR ELSE
#	if not free_polyominoes.is_empty():
#		return
	
	var polyBitMap: PolyBitMap = PolyBitMap.new()
	polyBitMap.create(Vector2i(size,size))
	polyBitMap.set_bitv(Vector2i(Vector2(size, size).clamp(Vector2.ZERO, Vector2i(size, size)) / 2), true)	
	var time = Time.get_unix_time_from_system()
	
	
	var broken_dicktionary: Dictionary
	broken_dicktionary[location] = polyBitMap
	for i in range(size):
		if broken_dicktionary == null:
			continue
		broken_dicktionary = paint(broken_dicktionary)
	
	unfinished = broken_dicktionary
	
	print(iteration)
	print(Time.get_time_string_from_unix_time(Time.get_unix_time_from_system() - time)  )
	
	polyomino_details["Speed: " + str(size)] = Time.get_time_string_from_unix_time(Time.get_unix_time_from_system() - time)
	
	ResourceSaver.save(self, resource_path)
	

func paint(broken_dicktionary: Dictionary):
	var temp_dictionary: Dictionary = {}
	for polyBitMap in broken_dicktionary.values():
		var walls: PackedVector2Array = polyBitMap.get_all_inner_walls()
		var next_steps: PackedVector2Array = polyBitMap.get_all_outer_walls(walls)
		
		for i in next_steps.size():
			var step_PolyBitMap: PolyBitMap = polyBitMap.duplicate()
			
			for j in next_steps.size():
				var next_step_PolyBitMap: PolyBitMap = step_PolyBitMap.duplicate()
				next_step_PolyBitMap.set_bitv(next_steps[(j + i) % next_steps.size()], true)
				if i % 2:
					step_PolyBitMap.set_bitv(next_steps[(j - i) % next_steps.size()], true)
				else:
					step_PolyBitMap.set_bitv(next_steps[(j - i - 1) % next_steps.size()], true)
				
				if next_step_PolyBitMap.get_true_bit_count() == size:
					add_to_polyominoes_dictionary(next_step_PolyBitMap)
				if next_step_PolyBitMap.get_true_bit_count() < size:
					temp_dictionary[next_step_PolyBitMap.get_all_inner_walls()] = next_step_PolyBitMap
				iteration += 1
			
	return temp_dictionary.duplicate()
	


func add_to_polyominoes_dictionary(_polyBitMap: PolyBitMap):
	
	if _polyBitMap.get_true_bit_count() == 0:
		print("Cannot add an empty PolyBitMap to Dictionary")
		return
	var poly_in_polyominoes: bool = false
	var rotated_PolyBitMaps: Array[PolyBitMap] = rotate(_polyBitMap)
	var fixed_PolyBitMaps: Array[PolyBitMap] = rotated_PolyBitMaps.duplicate()
	
	for PolyBitMap in rotated_PolyBitMaps:
		fixed_PolyBitMaps.append(flip(PolyBitMap))
	for fixed_PolyBitMap in fixed_PolyBitMaps:
		var packed_array = convert_PolyBitMap_to_array(fixed_PolyBitMap)
		if not packed_array in polyominoes.keys():
			polyominoes[packed_array] = fixed_PolyBitMap
		if packed_array in free_polyominoes.keys():
			poly_in_polyominoes = true
	
	if not poly_in_polyominoes:
		var packed_array = convert_PolyBitMap_to_array(fixed_PolyBitMaps[0])
		if not polyomino_details.get("size: " + str(size)):
			polyomino_details["size: " + str(size)] = 1
		else:
			polyomino_details["size: " + str(size)] += 1
		var name: = str(size) + "_" + str(polyomino_details["size: " + str(size)])
		free_polyominoes[packed_array] = fixed_PolyBitMaps[0]

###Works
func rotate(_PolyBitMap: PolyBitMap, rotations: int = 3) -> Array[PolyBitMap]:
	var _new_PolyBitMap: PolyBitMap = _PolyBitMap.duplicate()
	var rotated_PolyBitMaps: Array[PolyBitMap] = [align_shape(_new_PolyBitMap)]
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
