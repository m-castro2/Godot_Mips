extends Window

@onready var text_edit = $TextEdit
var parent: ClickableComponent = null


func _ready():
	Globals.cycle_changed.connect(update_info)
	Globals.program_loaded.connect(update_info)
	Globals.show_menu.connect(_on_show_menu)
	parent = get_parent()
	parent.is_window_active = true
	position.x = clamp(parent.global_position.x + parent.size.x/2 - size.x/2, 0, DisplayServer.window_get_size().x - size.x)
	position.y = clamp(parent.global_position.y + parent.size.y/2 - size.y/2, 40, DisplayServer.window_get_size().y - size.y)
	title = parent.window_title


func _on_close_requested() -> void:
	get_parent().is_window_active = false
	queue_free()


func show_info():
	add_info(parent.get_info())


func add_info(info) :
	if info:
		for value in info:
			text_edit.text += str(value) + "\n"


func update_info():
	text_edit.text = ""
	add_info(parent.get_info())


func _on_show_menu(value: bool):
	visible = !value
