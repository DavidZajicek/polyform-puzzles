extends CanvasGroup

@onready var poly: PackedScene = preload("res://Poly.tscn")
@onready var clickable_area: CollisionPolygon2D = $Area2D/ClickableArea
@onready var polyforms: Polyforms = preload("res://Polyforms.tres")

var array: BitMap = BitMap.new()

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
#	randomize()
#	var points: PackedVector2Array = generate_shape()
#	polyforms.generate_shape(2)
	polyforms.generate_shape(4)
#	polyforms.generate_shape(6)
#	create_clickable_area(points)
	generate_shape()
	connect_with_poly_children()
	

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
	for vector in polyforms.polyominoes[ polyforms.polyominoes.keys()[ randi() % polyforms.polyominoes.size() ] ]:
		var new_poly = poly.instantiate()
		add_child(new_poly)
		new_poly.position = vector * Globals.tile_size

func create_shape(count: int) -> void:
	for x in array.get_size().x:
		array.set_bit(x, count, true)
#func generate_shape() -> PackedVector2Array:
#	var grid = unique_polyominoes[unique_polyominoes.keys()[randi() % unique_polyominoes.size()]]
#	var y_index = 0
#	var points: PackedVector2Array
#
#	for y in grid:
#		var x_index = 0
#		y_index += 1
#
#		for x in y:
#			x_index += 1
#			if x == 1:
#				var new_poly = poly.instantiate()
#				add_child(new_poly)
#				new_poly.position = Vector2(x_index, y_index) * Globals.tile_size
#				points.append(new_poly.position)
#	return points
#
func connect_with_poly_children() -> void:
	for child in get_children():
		if child is Poly:
			areas.append(child)
			child.connect("mouse_entered", _on_child_mouse_entered)
			child.connect("mouse_exited", _on_child_mouse_exited)

func create_clickable_area(points: PackedVector2Array) -> void:
	var squares: PackedVector2Array
	for point in points:
		for corner in 4:
			squares.append(point * (corner+1)) # this is multiplying all 4 corners, I instead need to ADD 3 corners per square
	
#	clickable_area.set_polygon(squares)
#	for point in points:
#		clickable_area.points.append(point)
#	clickable_area.queue_redraw()

func _on_child_mouse_entered() -> void:
	mouse_over = true


func _on_child_mouse_exited() -> void:
	mouse_over = false
