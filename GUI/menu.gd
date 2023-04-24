extends Control

var has_mouse: bool = false

const ANIMATION_SPEED = 0.15


func show_menu():
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), ANIMATION_SPEED)


func hide_menu():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(-size.x,0), ANIMATION_SPEED)
	await tween.finished
	visible = false


func _on_close_menu_pressed():
	hide_menu()


func _on_mouse_entered():
	has_mouse = true


func _on_mouse_exited():
	has_mouse = false


func _on_load_program_pressed():
	Globals.show_load_program_menu.emit()
