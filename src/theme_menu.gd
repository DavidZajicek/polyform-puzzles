extends CanvasLayer

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/NavigationButtons/BackButton

var theme_data: ThemeData = preload("res://theme_data.tres")

func _ready() -> void:
	for block_texture in theme_data.block_textures.values():
		var new_rect: TextureRect = TextureRect.new()
		new_rect.texture = load(block_texture)
		v_box_container.add_child(new_rect)
		new_rect.gui_input.connect(update_block_texture.bind(new_rect.texture))
	back_button.pressed.connect(go_back.bind())

func go_back():
	get_tree().change_scene_to_file("res://settings_menu.tscn")
	

func update_block_texture(_event: InputEvent, new_texture):
	if _event is InputEventMouseButton and _event.is_action_pressed("left_mouse"):
		Globals.user_settings.block_texture = new_texture
		go_back()
