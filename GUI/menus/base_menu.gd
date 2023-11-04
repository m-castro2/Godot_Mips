extends Window

const LoadProgramMenu:= preload("res://menus/load_program_menu.tscn")
const SettingsMenu:= preload("res://menus/settings_menu.tscn")

var base_window_scale:= Vector2.ZERO

var child_has_focus:= false

func _ready():
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)
	close_requested.connect(_on_close_requested)
	#focus_exited.connect(_on_focus_exited)
	Globals.load_program_pressed.connect(_on_Globals_load_program_pressed)
	
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)


func instantiate_load_program_menu():
	title = "Load Program"
	var load_program_menu:= LoadProgramMenu.instantiate()
	add_child(load_program_menu)


func instantiate_settings_menu():
	title = "Settings"
	var settings_menu:= SettingsMenu.instantiate()
	settings_menu.option_button_focus_changed.connect(_on_option_button_focus_changed)
	add_child(settings_menu)


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	size = viewport_size / base_window_scale
	move_to_center()


func _on_close_requested():
	if get_child_count():
		get_child(0).queue_free()
	visible = false
	Globals.close_window_handled = false


func _on_focus_exited():
	var mouse_position:= get_viewport().get_mouse_position()
	if mouse_position.x > position.x and mouse_position.x < size.x \
			 and mouse_position.y > position.y and mouse_position.y < size.y:
		return
	
	if get_child_count():
		get_child(0).queue_free()
	visible = false
	Globals.close_window_handled = true


func _on_Globals_load_program_pressed(_file_path: String) -> void:
	_on_close_requested()


func _on_option_button_focus_changed(value: bool) -> void:
	child_has_focus = value
