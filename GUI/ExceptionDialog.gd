extends AcceptDialog

var base_window_scale:= Vector2.ZERO

func _ready():
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	size = viewport_size / base_window_scale


func add_info(exception_info: Dictionary):
	if exception_info["err_no"] == 259:
		# syscall exception
		title = "Syscall"
		if exception_info["err_msg"] != "Program done":
			dialog_text = exception_info["err_msg"] + ":0x"+ exception_info["err_v"]
		else:
			dialog_text = exception_info["err_msg"]
	else:
		title = "Exception caught"
		if exception_info["err_v"] != str(0):
			dialog_text = exception_info["err_msg"] + ": 0x" + exception_info["err_v"]
		else:
			dialog_text = exception_info["err_msg"]
	
	visible = true
