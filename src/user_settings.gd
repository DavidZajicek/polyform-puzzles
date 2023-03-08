class_name UserSettings
extends Resource

const USER_SETTINGS_BASE_PATH := "user://user_settings"

@export var background_colour: Color = Color(0.3, 0.3, 0.3, 1.0) : set = set_background_colour
@export var grid_tile_colour: Color = Color(0.0, 0.0, 1.0, 0.5) : set = set_grid_tile_colour
@export var drop_shadow_colour: Color = Color(0.0, 0.0, 0.0, 0.3) : set = set_drop_shadow_colour
@export var block_texture: CompressedTexture2D = preload("res://icon.svg") : set = set_block_texture
@export var pickup_offset: float = 64.0 : set = set_pickup_offset
@export var block_scale: float = 0.5 : set = set_block_scale
@export var break_time: int = 0 : set = set_break_time
@export var olister_mode: bool = false : set = set_olister_mode


func write_settings() -> void:
	ResourceSaver.save(self, UserSettings.get_settings_path())

static func settings_exists() -> bool:
	return ResourceLoader.exists(UserSettings.get_settings_path())

static func get_settings_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return USER_SETTINGS_BASE_PATH + extension

func set_background_colour(colour):
	background_colour = colour
	write_settings()

func set_grid_tile_colour(colour):
	grid_tile_colour = colour
	write_settings()

func set_drop_shadow_colour(colour):
	drop_shadow_colour = colour
	write_settings()

func set_block_texture(texture: CompressedTexture2D):
	block_texture = texture
	write_settings()

func set_pickup_offset(offset: float):
	pickup_offset = offset
	write_settings()

func set_block_scale(new_scale: float):
	block_scale = new_scale
	write_settings()

func set_break_time(new_time: int):
	break_time = new_time
	write_settings()

func set_olister_mode(new_value: bool):
	olister_mode = new_value
	write_settings()
