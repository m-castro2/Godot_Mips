extends Line2D

class_name OutsideLine2D

@export var origin: Marker2D
@export var target: Marker2D
@export var intersect_point: float
## true if the line goes from right to left
@export var flag: bool
@export var offset: int
@export var line_type: LineManager.if_lines

var active: bool :
	set(value):
		active = value
		z_index = 1 if value else 0
		default_color = Color.GREEN if value else Color.WHITE


func add_points():
	global_position = Vector2(0, 0)
	clear_points()
	var start: Vector2
	var end: Vector2
	start = origin.global_position
	add_point(start)
	end = origin.global_position
	var first_point = Vector2(start.x + (end.x - start.x)*intersect_point, start.y)
	add_point(first_point)
	if flag:
		add_point(Vector2(first_point.x, start.y))
		add_point(Vector2(target.global_position.x - offset, start.y))
		add_point(Vector2(target.global_position.x - offset, target.global_position.y))
	else:
		add_point(Vector2(first_point.x, target.global_position.y))
	add_point(target.global_position)


func _ready():
	LineManager.if_line_active.connect(_on_LineManager_if_line_active)


func _on_LineManager_if_line_active(p_line_type: LineManager.if_lines):
	if p_line_type == line_type:
		active = true
