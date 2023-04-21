extends Control

var has_mouse: bool = false

const ANIMATION_SPEED = 0.15

func _ready():
	pass#set_deferred("size", $PanelContainer.size)


func show_menu():
	self.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), ANIMATION_SPEED)


func hide_menu():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(-self.size.x,0), ANIMATION_SPEED)
	await tween.finished
	self.visible = false


func _on_close_menu_pressed():
	hide_menu()


func _on_resized():
	pass#set_deferred("size", $PanelContainer.size) #crashes if panelContainer anchored to leftWide????


func _on_mouse_entered():
	has_mouse = true


func _on_mouse_exited():
	has_mouse = false
