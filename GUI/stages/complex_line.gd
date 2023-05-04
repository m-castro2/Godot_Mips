extends Line2D

class_name ComplexLine2D

@export var origin: Line2D
@export var target: Marker2D
@export var intersect_point: float

var custom_points: Array[Vector2] = []


func add_points():
	global_position = Vector2(0, 0)
	custom_points.clear()
	var start: Vector2
	var end: Vector2
	start = origin.get_point_position(0)
	end = origin.get_point_position(1)
	var first_point = Vector2(start.x + (end.x - start.x)*intersect_point, start.y)
	custom_points.push_back(first_point)
	custom_points.push_back(Vector2(first_point.x, target.global_position.y))
	custom_points.push_back(target.global_position)
	points = custom_points
