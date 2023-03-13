extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = Globals.user_settings.block_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
