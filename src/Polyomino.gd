class_name Polyomino
extends CanvasGroup

@onready var poly: PackedScene = preload("res://Poly.tscn")
@onready var drop_shadow_poly: PackedScene = preload("res://DropShadowPoly.tscn")
@onready var polyforms_resource: Polyforms = preload("res://Polyforms.tres")
@onready var drop_shadow: CanvasGroup = $DropShadow

@export var size: int = 4

signal picked_up
signal put_down

var poly_bitmap: PolyBitMap

var offset: Vector2
var original_position: Vector2
var dragging
var clickable_areas: Array[ClickableArea]
var overlap_areas: Array[Area2D]
var mouse_over: bool = false
var scaled_poly := Vector2(Globals.user_settings.block_scale, Globals.user_settings.block_scale)

func _ready() -> void:
	
	randomize()
	generate_shape()
	connect_with_poly_children()
	
	scale = scaled_poly

func generate_shape() -> void:
	var size_poly = polyforms_resource.polyominoes[size]
	var score: int = 0
	poly_bitmap = size_poly[size_poly.keys()[randi() % size_poly.size()]]
	for vector in poly_bitmap.get_all_inner_walls():
		var new_poly = poly.instantiate()
		add_child(new_poly)
		new_poly.position = (vector * Globals.tile_size)
		var new_drop_shadow_poly = drop_shadow_poly.instantiate()
		new_drop_shadow_poly.position = (vector * Globals.tile_size)
		drop_shadow.add_child(new_drop_shadow_poly)
#		new_poly.label.text = str(new_poly.global_position)
		score += 1
	for child in get_children():
		if child is Poly:
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
			offset.y -= Globals.user_settings.pickup_offset
			dragging = self
			emit_signal("picked_up", self, offset)
			scale = Vector2(1, 1)
			dragging.drop_shadow.visible = true
			z_index = 1
		
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse"):
			if dragging == self:
				get_tree().get_root().set_input_as_handled()
				position = snapped(position, Globals.tile_size)
				await get_tree().process_frame
				for child in overlap_areas:
					if child.has_overlapping_areas():
						position = original_position
				emit_signal("put_down", self, position, original_position)
				
				scale = scaled_poly
				dragging.drop_shadow.visible = false
				dragging = null
				z_index = 0
