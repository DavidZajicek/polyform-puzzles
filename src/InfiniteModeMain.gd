class_name InfiniteModeMain
extends Node2D

@onready var grid: Grid = $Grid
@export var polyomino: PackedScene = preload("res://Polyomino.tscn")

var offset: Vector2
var dragging: Polyomino
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if Globals.top_score.top_scores.has(Globals.poly_size):
		$CanvasLayer/UserInterface/HBoxContainer/TopScore.text = "Top Score for size " + str(Globals.poly_size) + ": \n" + str(Globals.top_score.top_scores[Globals.poly_size])
	else:
		$CanvasLayer/UserInterface/HBoxContainer/TopScore.text = "Top Score for size " + str(Globals.poly_size) + ": \n0"
	$CanvasLayer/UserInterface/HBoxContainer/QuitButton.pressed.connect(save_and_quit.bind())
	$CanvasLayer/UserInterface/HBoxContainer/RestartButton.pressed.connect(save_and_reload.bind())

func _process(_delta: float) -> void:
	if not get_tree().get_nodes_in_group("polyominoes").size():
		for point in $SpawnPoints.get_children():
			spawn_polyomino(point.position)
		await get_tree().process_frame
		
		test_for_any_legal_moves()
	

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag or dragging and event is InputEventMouseMotion:
		dragging.position = event.position + offset
		dragging.drop_shadow.global_position = snapped(dragging.global_position, Globals.tile_size)
		
	
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	



func _on_Polyomino_picked_up_event(_polyomino: Polyomino, _offset: Vector2):
	dragging = _polyomino
	offset = _offset

func _on_Polyomino_put_down_event(_polyomino: Polyomino, _position: Vector2, _original_position: Vector2):
	var relative_position: Vector2 = snapped(dragging.position - grid.position, Globals.tile_size)
	var legal = test_if_legal(_polyomino, relative_position)
	if legal:
		for poly in _polyomino.get_children():
			if poly is Poly:
				var pos = snapped((poly.position + relative_position) / Globals.tile_size, Vector2(1, 1))
				grid.bitmap.set_bitv(pos, true)
				_polyomino.remove_child(poly)
				grid.add_child(poly)
				poly.destroy_poly.connect(_on_Poly_destroyed.bind())
				poly.position = snapped(pos * Globals.tile_size, Globals.tile_size)
		_polyomino.queue_free()
		if grid.bitmap.get_total_line_count():
			grid.destroy_lines()
	else:
		_polyomino.position = _original_position
	dragging = null
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("polyominoes").size() > 0:
		test_for_any_legal_moves()
	

func spawn_polyomino(_position):
	var new_polyomino = polyomino.instantiate()
	new_polyomino.position = _position
	new_polyomino.size = randi_range(1, Globals.poly_size)
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
	$CanvasLayer/UserInterface/HBoxContainer/ScoreLabel.text =  "Current Score: \n" + str(score)

func test_if_legal(_polyomino: Polyomino, _position: Vector2):
	for poly in _polyomino.get_children():
		if poly is Poly:
			var grid_pos = snapped((poly.position + _position) / Globals.tile_size, Vector2(1, 1))
			if not grid.rect.has_point(grid_pos):
				return false
			if grid.bitmap.get_bitv(grid_pos):
				return false
	return true

func test_for_any_legal_moves():
	var bitmap: PolyBitMap = grid.bitmap.duplicate()
	var legal_moves: int = 0
	for _polyomino in get_tree().get_nodes_in_group("polyominoes"):
		for x in bitmap.get_size().x:
			for y in bitmap.get_size().y:
				var _position: Vector2 = Vector2(x, y) * Globals.tile_size
				if test_if_legal(_polyomino, _position):
					legal_moves += 1
	$CanvasLayer/UserInterface/HBoxContainer/PossibleMoves.text =  "Possible Moves: \n" + str(legal_moves)
	if legal_moves == 0:
		save()
		$CanvasLayer/UserInterface/HBoxContainer/PossibleMoves.text = "No more moves,\nrestart? -->"


func save():
	
#	if score > Globals.top_score.top_score:
#		Globals.top_score.top_score = score
	
	Globals.top_score.set_scores(score)

func reload():
	get_tree().reload_current_scene()

func save_and_reload():
	save()
	reload()


func save_and_quit():
	save()
	get_tree().change_scene_to_file("res://InfiniteModeMainMenu.tscn")



