extends Window

var base_window_scale:= Vector2.ZERO

@onready var label = $MarginContainer/VBoxContainer/Label
@onready var line_edit = $MarginContainer/VBoxContainer/LineEdit

var exception_dict: Dictionary

func _ready():
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)
	#get_ok_button().theme_type_variation = "LoadProgramButton"


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	size = viewport_size / base_window_scale
	move_to_center()


func add_info(exception_info: Dictionary):
	line_edit.hide()
	if exception_info["err_no"] == 259 and \
			exception_info["syscall_id"] > 5 and exception_info["syscall_id"] < 9:
		title = "Syscall"
		label.text = exception_info["err_msg"]
		line_edit.show()
		exception_dict = exception_info
		visible = true
		return
		
		
		
		
	if exception_info["err_no"] == -1:
		title = "Error loading program"
		label.text = "Can't load program " + ProjectSettings.globalize_path(exception_info["err_v"])
		
	elif exception_info["err_no"] == 259:
		# syscall exception
		title = "Syscall"
		if exception_info["err_msg"] != "Program done":
			label.text = exception_info["err_msg"] + ":0x"+ exception_info["err_v"]
		else:
			label.text = exception_info["err_msg"]
	else:
		title = "Exception caught"
		if exception_info["err_v"] != str(0):
			label.text = exception_info["err_msg"] + ": 0x" + exception_info["err_v"]
		else:
			label.text = exception_info["err_msg"]
	
	visible = true


func _on_line_edit_text_submitted(new_text):
	visible = false
	exception_dict["err_msg"] = new_text
	PipelinedWrapper.execute_syscall_callback(exception_dict)


func _on_close_requested():
	hide()
