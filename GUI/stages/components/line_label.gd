class_name LineLabel
extends Label

@export var label_line_vertex: int
@export var label_orientation: bool
@export var label_padding: Vector2
@export var line: Line2D
@export var stage: int


func _ready():
	line.draw.connect(_on_line_drawn)
	line.visibility_changed.connect(_on_line_visibility_changed)
	
	if label_orientation:
		rotation_degrees = 270


func _on_line_drawn():
	global_position = line.get_point_position(label_line_vertex) + label_padding - Vector2(0, size.y)


func _on_line_visibility_changed():
	visible = line.visible
