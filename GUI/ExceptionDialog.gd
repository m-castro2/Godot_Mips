extends AcceptDialog

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
