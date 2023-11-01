extends Control

var has_mouse: bool = false

const ANIMATION_SPEED = 0.15

@onready var margin_container = $PanelContainer/MarginContainer
@onready var close_menu = $CloseMenu

func _ready():
	Globals.load_program_pressed.connect(_on_load_program_pressed)
	Globals.close_menu.connect(_on_close_menu)


func show_menu():
	Globals.show_menu.emit(true)
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), ANIMATION_SPEED)


func hide_menu():
	Globals.show_menu.emit(false)
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


func _on_load_program_pressed(_path: String): 
	hide_menu()


func _on_load_program_menu_pressed(): #signal from scene button
	Globals.show_load_program_menu.emit()


func _on_close_menu() -> void:
	hide_menu()


func _on_settings_pressed():
	Globals.show_settings_menu.emit()


func _on_close_menu_resized():
	margin_container.add_theme_constant_override("margin_top", max(10, close_menu.size.y))
