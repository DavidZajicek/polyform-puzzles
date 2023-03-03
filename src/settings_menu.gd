class_name SettingsMenu
extends CanvasLayer

const BASE_BLOCK_SIZE_LABEL: String = "[center]Max Block Size: "

@onready var difficulty_label: RichTextLabel = $MarginContainer/VBoxContainer/GridContainer/DifficultyLabel
@onready var difficulty_slider: HSlider = $MarginContainer/VBoxContainer/GridContainer/DifficultySlider
@onready var change_block_texture_button: TextureButton = $MarginContainer/VBoxContainer/GridContainer/ChangeBlockTextureButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/NavigationButtons/BackButton

@onready var theme_menu: = preload("res://theme_menu.tscn")

func _ready() -> void:
	change_block_texture_button.texture_normal = Globals.user_settings.block_texture
	change_block_texture_button.pressed.connect(func(): get_tree().change_scene_to_packed(theme_menu))
	difficulty_slider.value_changed.connect(func(value): difficulty_label.text = BASE_BLOCK_SIZE_LABEL + str(value) )
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
