extends Marker2D

var pos: Vector2 = position
@export var relative_position: Vector2

func get_updated_position() -> Vector2:
	var parent: Button = get_parent()
	return parent.global_position + relative_position
