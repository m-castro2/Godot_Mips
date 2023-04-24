extends Window

@onready var text_edit = $TextEdit


func _on_close_requested() -> void:
	queue_free()


func add_info(info, type: Globals.component_type) :
	match type:
		Globals.component_type.InstructionsMemory:
			for instruction in info:
				text_edit.text += instruction[1] +"\n"
				
