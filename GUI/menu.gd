extends Control

var has_mouse: bool = false

func _ready():
	set_deferred("size", $PanelContainer.size)


func show_menu():
	grab_focus()
	self.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), .15)


func hide_menu():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(-145,0), 0.15)
	await tween.finished
	self.visible = false


func _on_close_menu_pressed():
	hide_menu()


func _on_resized():
	set_deferred("size", $PanelContainer.size)


func _on_mouse_entered():
	has_mouse = true


func _on_mouse_exited():
	has_mouse = false
