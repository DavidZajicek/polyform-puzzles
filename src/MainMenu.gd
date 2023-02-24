extends Control

@onready var top_score: Scores
@onready var top_score_label: Label = $VBoxContainer/TopScore
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var difficulty_slider: HSlider = $VBoxContainer/DifficultySlider
@onready var difficulty_label: Label = $VBoxContainer/DifficultyLabel

@onready var main_game: PackedScene = load("res://Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_or_load_save()
	top_score_label.text = "Top Score: \n" + str(top_score.top_score)
	start_button.pressed.connect(start_game.bind())
	quit_button.pressed.connect(get_tree().quit)
	difficulty_slider.value_changed.connect(update_difficulty_label)
	difficulty_slider.value = Globals.poly_size
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _create_or_load_save():
	if Scores.save_exists():
		top_score = load("user://topscore.tres")
	else:
		top_score = Scores.new()

func start_game():
	Globals.poly_size = difficulty_slider.value
	get_tree().change_scene_to_packed(main_game)

func update_difficulty_label(value):
	difficulty_label.text = "Max Block Size: \n" + str(value)
