extends Camera2D

@export var min_zoom: = 0.5
@export var max_zoom: = 2.0
@export var zoom_factor: = 0.1

var _zoom_level: = 1.0 : set = _set_zoom_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_zoom_level(value: float):
	_zoom_level = clamp(value, min_zoom, max_zoom)
	zoom = Vector2(_zoom_level, _zoom_level)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
