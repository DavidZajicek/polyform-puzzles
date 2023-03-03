class_name MainMenu
extends CanvasLayer

@onready var infinite_mode: Button = $MainMenu/MarginContainer/VBoxContainer/InfiniteMode
@onready var puzzle_mode: Button = $MainMenu/MarginContainer/VBoxContainer/PuzzleMode
@onready var settings_menu: Button = $MainMenu/MarginContainer/VBoxContainer/SettingsMenu
@onready var top_scores: Button = $MainMenu/MarginContainer/VBoxContainer/TopScores
@onready var exit_game: Button = $MainMenu/MarginContainer/VBoxContainer/ExitGame


@onready var infinite_mode_scene: PackedScene = load("res://InfiniteModeMain.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	infinite_mode.pressed.connect(func(): get_tree().change_scene_to_packed(infinite_mode_scene))
	settings_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://settings_menu.tscn"))
	exit_game.pressed.connect(func(): get_tree().quit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
