class_name MainMenu
extends CanvasLayer


@onready var title: RichTextLabel = $MainMenu/MarginContainer/VBoxContainer/Title
@onready var infinite_mode: Button = $MainMenu/MarginContainer/VBoxContainer/InfiniteMode
@onready var puzzle_mode: Button = $MainMenu/MarginContainer/VBoxContainer/PuzzleMode
@onready var settings_menu: Button = $MainMenu/MarginContainer/VBoxContainer/SettingsMenu
@onready var top_scores: Button = $MainMenu/MarginContainer/VBoxContainer/TopScores
@onready var exit_game: Button = $MainMenu/MarginContainer/VBoxContainer/ExitGame


@onready var infinite_mode_scene: PackedScene = load("res://InfiniteModeMainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	infinite_mode.pressed.connect(func(): get_tree().change_scene_to_packed(infinite_mode_scene))
	settings_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://settings_menu.tscn"))
	exit_game.pressed.connect(func(): get_tree().quit())
	title.push_color(Color(randf(), randf(), randf()))
	title.append_text("[center]Poly Pals[/center]")

