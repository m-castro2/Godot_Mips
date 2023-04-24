extends Control

var expanded = false


func _on_stage_button_pressed():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 3, 0.15)
	expanded = !expanded


func _on_instructions_memory_button_pressed():
	Globals.show_instructions_memory.emit()
