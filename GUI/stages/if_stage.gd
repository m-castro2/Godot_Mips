extends Control


var expanded = false


func _ready() -> void:
	StageControl.update_stage_colors.connect(_on_update_stage_colors)


func _on_stage_button_pressed():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 3, 0.15)
	expanded = !expanded


func _on_instructions_memory_button_pressed():
	Globals.show_instructions_memory.emit()


func _on_update_stage_colors(colors_map, instructions):
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox.bg_color = colors_map[instructions[0]]
	$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)
