extends CanvasGroup

@onready var poly: PackedScene = preload("res://Poly.tscn")
@onready var polyforms_resource: Polyforms = preload("res://Polyforms.tres")
@export var size: int = 4



var offset: Vector2
var original_position: Vector2
var dragging
var clickable_areas: Array[ClickableArea]
var overlap_areas: Array[Area2D]
var mouse_over: bool = false

func _ready() -> void:
	
	randomize()
#	var points: PackedVector2Array = generate_shape()
#	polyforms_resource.generate_shape(1)
#	polyforms_resource.generate_shape(2)
#	polyforms_resource.generate_shape(3)
#	polyforms_resource.generate_shape(4) #19/5
#	polyforms_resource.generate_shape(5) #63/12
#	polyforms_resource.generate_shape(6) #216/35 (all shapes) 00:03
#	polyforms_resource.generate_shape(7) #760/108 (all shapes) 0:27
#	polyforms_resource.generate_shape(8) #2725/369 (all shapes) 4:47
#	polyforms_resource.generate_shape(9) #9910/1285 (all shapes) 01:40:34
#	polyforms_resource.generate_shape(10) #36446/4655 5 hours
#	create_clickable_area(points)
#	generate_shape(size)
#	connect_with_poly_children()
	


#func _physics_process(delta: float) -> void:
#	if dragging:
#		var mouse_pos: Vector2 = InputEventScreenDrag.position
#		position = mouse_pos + offset

#func _input(event: InputEvent) -> void:
#
##	if Input.is_action_just_pressed("left_mouse") and mouse_over:
##		if Input.is_action_just_pressed("left_mouse"):
##			original_position = position
##			offset = position - get_global_mouse_position()
##			dragging = true
##			get_tree().get_root().set_input_as_handled()
##			z_index = 1
#	if Input.is_action_just_released("left_mouse") and dragging:
#		position = snapped(position, Vector2(32,32))
#		for child in overlap_areas:
#			if child.has_overlapping_areas():
#				position = original_position
#		dragging = false
#		z_index = 0
#

func generate_shape(size: int) -> void:
	var size_poly = polyforms_resource.polyominoes[size]
	for vector in size_poly[size_poly.keys()[randi() % size_poly.size()]].get_all_inner_walls():
		var new_poly = poly.instantiate()
		add_child(new_poly)
		new_poly.position = vector * Globals.tile_size


func connect_with_poly_children() -> void:
	for child in get_children():
		if child is Poly:
			overlap_areas.append(child)
			for polys_ClickableArea in child.get_children():
				if polys_ClickableArea is ClickableArea:
					clickable_areas.append(polys_ClickableArea)
					polys_ClickableArea.input_event.connect(_on_ClickableChild_event.bind())


func _on_ClickableChild_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			get_tree().get_root().set_input_as_handled()
			original_position = position
			offset = position - event.position
			dragging = self
			z_index = 1
		else:
			if dragging == self:
				get_tree().get_root().set_input_as_handled()
				position = snapped(position, Vector2(32,32))
				for child in overlap_areas:
					if child.has_overlapping_areas():
						position = original_position
				dragging = null
				z_index = 0
	
	if dragging:
		position = event.position + offset

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag:
		position = event.position + offset
	
