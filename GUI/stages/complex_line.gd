extends Line2D

class_name ComplexLine2D

@export var origin: Line2D
@export var target: Marker2D
@export var intersect_point: float
@export var flag: bool
@export var offset: int


func add_points():
	global_position = Vector2(0, 0)
	clear_points()
	var start: Vector2
	var end: Vector2
	start = origin.get_point_position(0)
	end = origin.get_point_position(1)
	var first_point = Vector2(start.x + (end.x - start.x)*intersect_point, start.y)
	add_point(first_point)
	if flag:
		add_point(Vector2(first_point.x, start.y - offset))
		add_point(Vector2(target.global_position.x - offset, start.y - offset))
		add_point(Vector2(target.global_position.x - offset, target.global_position.y))
	else:
		add_point(Vector2(first_point.x, target.global_position.y))
	add_point(target.global_position)
