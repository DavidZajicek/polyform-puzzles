extends CanvasGroup

@onready var poly: PackedScene = preload("res://Poly.tscn")

#make this a resource
var unique_polyominoes: Dictionary = {
	"Straight Block" : 
		[
		[1, 0, 0, 0],
		[1, 0, 0, 0],
		[1, 0, 0, 0],
		[1, 0, 0, 0]
		],
	"Gay Block" : 
		[
		[1, 0, 0, 0],
		[1, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0]
		]
}

var offset: Vector2
var original_position: Vector2
var dragging: bool = false
var areas: Array
var mouse_over: bool = false

func _ready() -> void:
	randomize()
	generate_shape()
	for child in get_children():
		if child is Poly:
			areas.append(child)
			child.connect("mouse_entered", _on_child_mouse_entered)
			child.connect("mouse_exited", _on_child_mouse_exited)

func _physics_process(delta: float) -> void:
	if dragging:
		var mouse_pos: Vector2 = get_global_mouse_position()
		position = mouse_pos + offset

func _input(event: InputEvent) -> void:
	if mouse_over:
		if Input.is_action_just_pressed("left_mouse"):
			original_position = position
			offset = position - get_global_mouse_position()
			dragging = true
	if Input.is_action_just_released("left_mouse") and dragging:
		position = snapped(position, Vector2(32,32))
		for child in areas:
			if child.has_overlapping_areas():
				position = original_position
		dragging = false

func generate_shape() -> void:
	var grid = unique_polyominoes[unique_polyominoes.keys()[randi() % unique_polyominoes.size()]]
	var y_index = 0
	
	for y in grid:
		y_index += 1
		var x_index = 0
		
		for x in y:
			x_index += 1
			if x == 1:
				var new_poly = poly.instantiate()
				add_child(new_poly)
				new_poly.position = Vector2(x_index, y_index) * Globals.tile_size

func _on_child_mouse_entered() -> void:
	mouse_over = true


func _on_child_mouse_exited() -> void:
	mouse_over = false
