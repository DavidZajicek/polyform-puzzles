class_name InfiniteModeMain
extends Node2D

@export var polyomino: PackedScene = preload("res://Polyomino.tscn")

@onready var grid: Grid = $Grid
@onready var break_button: Button = $CanvasLayer/UserInterface/BreakButton
@onready var hint_timer: Timer = $HintTimer

var offset: Vector2
var dragging: Polyomino
var drop_position: Vector2

var score: int = 0
var game_ended := false
var possible_moves: = 0

var best_move_dictionary: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if Globals.top_score.top_scores.has(Globals.poly_size):
		$CanvasLayer/UserInterface/HBoxContainer/TopScore.text = "Top Score for size " + str(Globals.poly_size) + ": \n" + str(Globals.top_score.top_scores[Globals.poly_size])
	else:
		$CanvasLayer/UserInterface/HBoxContainer/TopScore.text = "Top Score for size " + str(Globals.poly_size) + ": \n0"
	$CanvasLayer/UserInterface/HBoxContainer/QuitButton.pressed.connect(save_and_quit.bind())
	$CanvasLayer/UserInterface/HBoxContainer/RestartButton.pressed.connect(save_and_reload.bind())
#	hint_timer.timeout.connect(show_random_best_move.bind())
	hint_timer.start()
	break_button.pressed.connect(accept_break_warning.bind())

func _process(_delta: float) -> void:
	if not get_tree().get_nodes_in_group("polyominoes").size():
		for point in get_tree().get_nodes_in_group("spawn_points"):
			spawn_polyomino(point.global_position)
		await get_tree().process_frame
		
		test_for_any_legal_moves()
#	if possible_moves:
#		show_random_best_move()
	

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag or dragging and event is InputEventMouseMotion:
		dragging.position = event.position + offset
		drop_position = snapped(dragging.global_position, Globals.tile_size)
		dragging.drop_shadow.global_position = drop_position 
		var legal := test_if_legal(dragging, drop_position - grid.position)
		if not legal:
			dragging.drop_shadow.modulate = Color(1.0, 0.0, 0.0, 0.6)
		else:
			dragging.drop_shadow.modulate = Globals.user_settings.drop_shadow_colour
		
	
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("ui_accept") and not game_ended:
		show_random_best_move()



func _on_Polyomino_picked_up_event(_polyomino: Polyomino, _offset: Vector2):
	dragging = _polyomino
	offset = _offset

func _on_Polyomino_put_down_event(_polyomino: Polyomino, _position: Vector2, _original_position: Vector2):
	var relative_position: Vector2 = snapped(drop_position - grid.position, Globals.tile_size)
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

func test_if_legal(_polyomino: Polyomino, _position: Vector2) -> bool:
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
	var legal_moves: Array = []
	var most_adjacent_blocks: int = 0
	best_move_dictionary = {}
	for _polyomino in get_tree().get_nodes_in_group("polyominoes"):
		var best_moves: PackedVector2Array = []
		for x in bitmap.get_size().x:
			for y in bitmap.get_size().y:
				var _position: Vector2 = Vector2(x, y) * Globals.tile_size
				if test_if_legal(_polyomino, _position):
					legal_moves.append(Vector2(x, y))
					var adjacent_blocks = check_best_move(_polyomino.poly_bitmap.get_all_outer_edges(_polyomino.poly_bitmap.get_all_inner_walls()), Vector2(x, y))
					if adjacent_blocks > most_adjacent_blocks:
						most_adjacent_blocks = adjacent_blocks
						best_moves = [Vector2i(x, y)]
					elif adjacent_blocks == most_adjacent_blocks:
						best_moves.append(Vector2i(x, y))
		best_move_dictionary[_polyomino] = best_moves
	$CanvasLayer/UserInterface/HBoxContainer/PossibleMoves.text =  "Possible Moves: \n" + str(legal_moves.size())
	possible_moves = legal_moves.size()
	if legal_moves.size() == 0:
		save()
		$CanvasLayer/UserInterface/HBoxContainer/PossibleMoves.text = "No more moves,\nrestart? -->"
		game_ended = true


func save():
	
	
	Globals.top_score.set_scores(score)
	
	if Globals.break_time:
		break_button.show()
		Globals.break_time = false
		await break_button.pressed
	

func reload():
	get_tree().reload_current_scene()

func save_and_reload():
	await save()
	reload()


func save_and_quit():
	save()
	get_tree().change_scene_to_file("res://InfiniteModeMainMenu.tscn")


func accept_break_warning() -> bool:
	
	break_button.hide()
	Globals.start_break_timer()
	return true

func break_warning_prompt() -> bool:
	while Globals.break_time:
		continue
	return true

func check_best_move(points: PackedVector2Array, grid_pos: Vector2):
	var count: int = 0
	for point in points:
		if not grid.rect.has_point(point + grid_pos):
			continue
		if grid.bitmap.get_bitv(point + grid_pos):
			count += 1
	
	return count

func show_random_best_move():
	for _polyomino in get_tree().get_nodes_in_group("polyominoes"):
		if best_move_dictionary[_polyomino]:
			var location: Vector2 = best_move_dictionary[_polyomino][randi() % best_move_dictionary[_polyomino].size()]
#			dragging = _polyomino
#			_polyomino.emit_signal("put_down", _polyomino, (location * Globals.tile_size) + grid.position, _polyomino.position)
			_polyomino.drop_shadow.global_position = (location * Globals.tile_size) + grid.position
			_polyomino.drop_shadow.show()
			return
