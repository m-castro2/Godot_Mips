extends Window

@onready var text_edit = $TextEdit


func _on_close_requested() -> void:
	queue_free()


func add_info(info) :
	if info:
		for value in info:
			text_edit.text += str(value) + "\n"
