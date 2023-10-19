extends Marker2D

signal marker_updated
@export var last_position:= Vector2.ZERO
var updated:= false
func _physics_process(_delta):
	if last_position != global_position:
		last_position = global_position
		updated = false
	elif !updated:
		updated = true
		marker_updated.emit()
