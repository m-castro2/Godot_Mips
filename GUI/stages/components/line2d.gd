extends Line2D
class_name Line

@export var origin: Marker2D
@export var target: Marker2D

var active: bool :
	set(value):
		active = value
		z_index = 1 if value else 0
		default_color = Color.GREEN if value else Color.WHITE


func add_points():
	clear_points()
	global_position = Vector2.ZERO
	add_point(origin.global_position)
	add_point(target.global_position)


func get_line_points() -> Array[Vector2]:
	return [origin.global_position, target.global_position]
