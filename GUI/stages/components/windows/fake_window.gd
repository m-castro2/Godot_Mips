extends PanelContainer

@onready var title_label: Label = $VBoxContainer/PanelContainer/HBoxContainer/TitleLabel

@export var title: String:
	set(value):
		title_label.text = value


func _on_focus_exited():
	visible =false


func _on_close_button_pressed():
	visible = false
