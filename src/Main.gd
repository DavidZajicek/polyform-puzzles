extends Node2D

@onready var grid: Node2D = $Grid
@onready var top_score: Resource = ResourceLoader.load("user://top_score.tres")

@export var polyomino: PackedScene = preload("res://Polyomino.tscn")

var dragging
var offset: Vector2
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$UserInterface/TopScore.text = str(top_score.top_score)

func _process(_delta: float) -> void:
	if not get_tree().get_nodes_in_group("polyominoes").size():
		for point in $SpawnPoints.get_children():
			spawn_polyomino(point.position)
		test_for_any_legal_moves()

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag or dragging and event is InputEventMouseMotion:
		dragging.position = event.position + offset
	
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	

func _on_Polyomino_picked_up_event(_polyomino: Polyomino, _offset: Vector2):
	dragging = _polyomino
	offset = _offset

func _on_Polyomino_put_down_event(_polyomino: Polyomino, _position: Vector2, _original_position: Vector2):
	var legal = test_if_legal(_polyomino)
	if legal:
		for poly in _polyomino.get_children():
			var pos = poly.global_position - grid.global_position
			grid.bitmap.set_bitv(pos / Globals.tile_size, true)
			_polyomino.remove_child(poly)
			grid.add_child(poly)
			
			poly.destroy_poly.connect(_on_Poly_destroyed.bind())
			poly.position = pos
		_polyomino.queue_free()
		if grid.bitmap.get_total_line_count():
			grid.destroy_lines()
	else:
		_polyomino.position = _original_position
	dragging = null
	await get_tree().process_frame
	print(get_tree().get_nodes_in_group("polyominoes").size())
	if get_tree().get_nodes_in_group("polyominoes").size() > 0:
		test_for_any_legal_moves()
	

func spawn_polyomino(_position):
	var new_polyomino = polyomino.instantiate()
	new_polyomino.position = _position
	new_polyomino.size = randi_range(1, 6)
	add_child(new_polyomino)
	bind_polyominoes()

func bind_polyominoes():
	for child in get_children():
			if child is Polyomino:
				if not child.is_connected("picked_up", _on_Polyomino_picked_up_event.bind()):
					child.picked_up.connect(_on_Polyomino_picked_up_event.bind())
				if not child.is_connected("put_down", _on_Polyomino_put_down_event.bind()):
					child.put_down.connect(_on_Polyomino_put_down_event.bind())

func _on_Poly_destroyed(_score: int):
	score += _score
	$UserInterface/ScoreLabel.text = str(score)

func test_if_legal(_polyomino):
	for poly in _polyomino.get_children():
		var pos = poly.global_position - grid.global_position
		if not grid.rect.has_point(pos):
			return false
	return true

func test_for_any_legal_moves():
	var bitmap: PolyBitMap = grid.bitmap.duplicate()
	var legal_moves: int = 0
	for _polyomino in get_tree().get_nodes_in_group("polyominoes"):
		var illegal_moves: int = 0
		for x in bitmap.get_size().x:
			for y in bitmap.get_size().y:
				if not bitmap.get_bit(x, y):
					for poly in _polyomino.get_children():
						var pos = poly.position / Globals.tile_size
						if bitmap.get_bitv(pos):
							illegal_moves += 1
					
		if not illegal_moves:
			legal_moves += 1
	if legal_moves == 0:
		if score > top_score.top_score:
			top_score.top_score = score
		get_tree().reload_current_scene()








