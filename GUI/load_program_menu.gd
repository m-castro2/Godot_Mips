extends PanelContainer

@onready var name_container: VBoxContainer = %NameVBoxContainer
@onready var code_container: VBoxContainer = %CodeVBoxContainer
@onready var load_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/CodeVBoxContainer/LoadButton
@onready var description_label = $MarginContainer/VBoxContainer/HBoxContainer/CodeVBoxContainer/DescriptionLabel
@onready var code_label = $MarginContainer/VBoxContainer/HBoxContainer/CodeVBoxContainer/PanelContainer/ScrollContainer/CodeLabel

var file_path: String = ""

func _ready() -> void:
	Globals.can_instantiate_load_menu = false
	Globals.active_menu = "load_program"
	check_files()


func check_files() -> void:
	var dir: DirAccess = null
	if OS.has_feature("editor") or OS.has_feature("web") or OS.has_feature("android"):
		# Running from editor or web
		dir = DirAccess.open("res://testdata")
	else:
		# Running from export
		dir = DirAccess.open("user://testdata")
	if !dir:
		print("An error occurred when trying to access the path.")
		return
	
	var files:= dir.get_files()
	for file in files:
		if !file.get_extension() == "s":
			continue
		var file_name:= file.left(-2)
		var exists:= (file_name + ".tres") in files
		if (OS.has_feature("android") or OS.has_feature("web")) and \
				!(file_name + ".tres") in files:
			continue
		
		var button: Button = Button.new()
		button.text = file
		button.pressed.connect(_on_program_name_pressed.bind(file))
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.clip_text = true
		button.size_flags_horizontal =Control.SIZE_EXPAND_FILL
		button.theme_type_variation = "ButtonMenu"
		name_container.add_child(button)


func _on_program_name_pressed(file_name: String) -> void:
	if OS.has_feature("android") or OS.has_feature("web"):
		file_path = "res://testdata/" + file_name
	else:
		file_path = "user://testdata/" + file_name
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	description_label.text = file_name.get_basename() #update files to have description on first line?
	code_label.text = content
	load_button.disabled = false


func _exit_tree() -> void:
	Globals.active_menu = ""
	Globals.can_instantiate_load_menu = true


func _on_close_pressed():
	Globals.close_menu.emit()
	queue_free()


func _on_load_button_pressed():
	Globals.load_program_pressed.emit(file_path)
	#queue_free()
