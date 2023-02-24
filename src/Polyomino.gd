class_name Polyomino
extends CanvasGroup

@onready var poly: PackedScene = preload("res://Poly.tscn")
@onready var polyforms_resource: Polyforms = preload("res://Polyforms.tres")
@export var size: int = 4

signal picked_up
signal put_down

var offset: Vector2
var original_position: Vector2
var dragging
var clickable_areas: Array[ClickableArea]
var overlap_areas: Array[Area2D]
var mouse_over: bool = false

func _ready() -> void:
	
	randomize()
	generate_shape()
	connect_with_poly_children()
	

func generate_shape() -> void:
	var size_poly = polyforms_resource.polyominoes[size]
	var score: int = 0
	for vector in size_poly[size_poly.keys()[randi() % size_poly.size()]].get_all_inner_walls():
		var new_poly = poly.instantiate()
		add_child(new_poly)
		new_poly.position = (vector * Globals.tile_size)
#		new_poly.label.text = str(new_poly.global_position)
		score += 1
	for child in get_children():
		child.score = score * score


func connect_with_poly_children() -> void:
	for child in get_children():
		if child is Poly:
			overlap_areas.append(child)
			for polys_ClickableArea in child.get_children():
				if polys_ClickableArea is ClickableArea:
					clickable_areas.append(polys_ClickableArea)
					polys_ClickableArea.input_event.connect(_on_ClickableChild_event.bind())


func _on_ClickableChild_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed() and not dragging:
			get_tree().get_root().set_input_as_handled()
			original_position = position
			offset = position - event.position
			dragging = self
			emit_signal("picked_up", self, offset)
			z_index = 1
		elif event.is_action_released("left_mouse"):
			if dragging == self:
				get_tree().get_root().set_input_as_handled()
				position = snapped(position, Vector2(32,32))
				for child in overlap_areas:
					if child.has_overlapping_areas():
						position = original_position
				emit_signal("put_down", self, position, original_position)
				dragging = null
				z_index = 0
	

