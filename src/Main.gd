extends Node2D

@onready var grid: Node2D = $Grid
@export var polyomino: PackedScene = preload("res://Polyomino.tscn")

var dragging
var offset: Vector2
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

func _process(_delta: float) -> void:
	if not get_tree().get_nodes_in_group("polyominoes").size():
		for point in $SpawnPoints.get_children():
			spawn_polyomino(point.position)

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag or dragging and event is InputEventMouseMotion:
		dragging.position = event.position + offset
	
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	

func _on_Polyomino_picked_up_event(_polyomino: Polyomino, _offset: Vector2):
	dragging = _polyomino
	offset = _offset

func _on_Polyomino_put_down_event(_polyomino: Polyomino, _position: Vector2, _original_position: Vector2):
	var legal: bool = true
	for poly in _polyomino.get_children():
		var pos = poly.global_position - grid.global_position
		if not grid.rect.has_point(pos):
			_polyomino.position = _original_position
			legal = false
			break
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
	dragging = null
	

func spawn_polyomino(_position):
	var new_poly = polyomino.instantiate()
	new_poly.position = _position
	new_poly.size = randi_range(1, 10)
	add_child(new_poly)
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



