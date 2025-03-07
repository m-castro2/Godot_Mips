extends Window
class_name BaseWindow

@onready var base_window_scale:= Vector2.ZERO

func _enter_tree():
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)


func _ready():
	close_requested.connect(_on_close_requested)
	focus_exited.connect(_on_focus_exited)


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	size = viewport_size / base_window_scale
	move_to_center()


func _on_close_requested():
	visible = false
	Globals.close_window_handled = false

func _on_focus_exited():
	visible = false
	Globals.close_window_handled = true
