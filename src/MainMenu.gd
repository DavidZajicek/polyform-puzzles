extends Control

@onready var top_score_label: Label = $VBoxContainer/TopScore
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var difficulty_slider: HSlider = $VBoxContainer/DifficultySlider
@onready var difficulty_label: Label = $VBoxContainer/DifficultyLabel
@onready var difficulty_top_score: Label = $VBoxContainer/DifficultyTopScore

@onready var main_game: PackedScene = load("res://Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_score_label.text = "Top Score: \n" + str(Globals.top_score.top_score)
	start_button.pressed.connect(start_game.bind())
	quit_button.pressed.connect(get_tree().quit)
	difficulty_slider.value_changed.connect(update_difficulty_label)
	difficulty_slider.value = Globals.poly_size
	
	update_difficulty_label(Globals.poly_size)
	




func start_game():
	Globals.poly_size = int(difficulty_slider.value)
	get_tree().change_scene_to_packed(main_game)

func update_difficulty_label(value: int):
	difficulty_label.text = "Max Block Size: \n" + str(value)
	if Globals.top_score.top_scores.has(value):
		difficulty_top_score.text = "Top Score for size " + str(value) + ": \n" + str(Globals.top_score.top_scores[value])
	else:
		difficulty_top_score.text = "Top Score for size " + str(value) + ": \n0"
