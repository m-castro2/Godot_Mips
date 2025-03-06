extends BaseButton
class_name ClickableComponent

const WINDOW = preload("res://component_info_window.tscn")

var is_window_active: bool = false
@export var window_title: String

@export var inputs: Array[Marker2D]
@export var outputs: Array[Marker2D]
