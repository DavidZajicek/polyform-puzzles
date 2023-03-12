class_name SettingsMenu
extends CanvasLayer

const BASE_BLOCK_SIZE_LABEL: String = "[center]Max Block Size: "

@onready var difficulty_label: RichTextLabel = $MarginContainer/VBoxContainer/GridContainer/DifficultyLabel
@onready var difficulty_slider: HSlider = $MarginContainer/VBoxContainer/GridContainer/DifficultySlider

@onready var offset_slider: HSlider = $MarginContainer/VBoxContainer/GridContainer/OffsetSlider

@onready var background_colour_picker: ColorPickerButton = $MarginContainer/VBoxContainer/GridContainer/BackgroundColourPicker
@onready var grid_tile_colour_picker: ColorPickerButton = $MarginContainer/VBoxContainer/GridContainer/GridTileColourPicker
@onready var block_tray_scale_slider: HSlider = $MarginContainer/VBoxContainer/GridContainer/BlockTrayScaleSlider

@onready var break_time_label: RichTextLabel = $MarginContainer/VBoxContainer/GridContainer/BreakTimeLabel
@onready var break_time_slider: HSlider = $MarginContainer/VBoxContainer/GridContainer/BreakTimeSlider

@onready var check_button: CheckButton = $MarginContainer/VBoxContainer/GridContainer/CheckButton


@onready var change_block_texture_button: TextureButton = $MarginContainer/VBoxContainer/GridContainer/ChangeBlockTextureButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/NavigationButtons/BackButton

@onready var theme_menu: = preload("res://theme_menu.tscn")

func _ready() -> void:
	difficulty_slider.value_changed.connect(func(value): difficulty_label.text = BASE_BLOCK_SIZE_LABEL + str(value) )
	
	background_colour_picker.color_changed.connect(change_background_colour.bind())
	grid_tile_colour_picker.color_changed.connect(change_grid_tile_colour.bind())
	
	change_block_texture_button.texture_normal = Globals.user_settings.block_texture
	change_block_texture_button.pressed.connect(func(): get_tree().change_scene_to_packed(theme_menu))
	
	offset_slider.value = Globals.user_settings.pickup_offset
	offset_slider.value_changed.connect(func(value): Globals.user_settings.pickup_offset = value)
	
	block_tray_scale_slider.value = Globals.user_settings.block_scale
	block_tray_scale_slider.value_changed.connect(change_scale.bind())
	
	break_time_slider.value_changed.connect(change_break_timer.bind())
	@warning_ignore("integer_division")
	break_time_slider.value = Globals.user_settings.break_time / 60
	
	check_button.set_pressed_no_signal(Globals.user_settings.olister_mode)
	check_button.toggled.connect(func(new_value): Globals.user_settings.olister_mode = new_value)
	
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))


func change_background_colour(colour):
	Globals.user_settings.background_colour = colour
	RenderingServer.set_default_clear_color(colour)

func change_grid_tile_colour(colour):
	Globals.user_settings.grid_tile_colour = colour

func change_scale(new_scale: float):
	Globals.user_settings.block_scale = new_scale
	

func change_break_timer(new_time: int):
	Globals.user_settings.break_time = new_time * 60
	break_time_label.text = "[center]Change Break Reminder Timer:\n" + str(new_time) + " Minutes[/center]"
	if new_time == 0:
		Globals.break_timer.stop()
	else:
		Globals.start_break_timer()
