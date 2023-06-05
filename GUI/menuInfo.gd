extends Control

@onready var name_container: VBoxContainer = %NameVBoxContainer
@onready var code_container: VBoxContainer = %CodeVBoxContainer

var file_path: String = ""

func _ready() -> void:
	Globals.can_instantiate_load_menu = false
	Globals.active_menu = "load_program"
	check_files()


func check_files() -> void:
	var dir: DirAccess = null
	if OS.has_feature("editor"):
		# Running from editor
		dir = DirAccess.open("res://testdata")
	else:
		# Running from export
		dir = DirAccess.open(OS.get_executable_path().get_base_dir().path_join("testdata"))
	if !dir:
		print("An error occurred when trying to access the path.")
		return
		
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			print("Found dir: " + file_name)
			file_name = dir.get_next()
			continue
		if !file_name.get_extension() == "s":
			print("Skipping " + file_name + ": not a source file")
			file_name = dir.get_next()
			continue
			
		var button: Button = Button.new()
		button.text = file_name
		button.pressed.connect(_on_program_name_pressed.bind(file_name))
		button.size_flags_horizontal =Control.SIZE_SHRINK_CENTER
		name_container.add_child(button)
		file_name = dir.get_next()


func _on_program_name_pressed(file_name: String) -> void:
	file_path = "testdata/" + file_name
	var file: FileAccess = FileAccess.open("user://" + file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	(code_container.get_node("DescriptionLabel") as Label).text = content.left(content.find("\n")) #update files to have description on first line?
	(code_container.get_node("CodeEdit") as CodeEdit).text = content


func _on_load_pressed():
	Globals.load_program_pressed.emit(file_path)
	queue_free()


func _exit_tree() -> void:
	Globals.active_menu = ""
	Globals.can_instantiate_load_menu = true


func _on_close_pressed():
	Globals.close_menu.emit()
	queue_free()
