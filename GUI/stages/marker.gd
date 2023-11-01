extends Marker2D

@export var position_percent: Vector2 = Vector2.ZERO
@onready var parent:= (get_parent() as Control)

func _ready() -> void:
	parent.resized.connect(_on_parent_resized)
	if position_percent == Vector2.ZERO:
		position_percent = position / parent.size
	_on_parent_resized()


func _on_parent_resized() -> void:
	position = parent.size * position_percent


func _process(delta):
	if position_percent == Vector2.ZERO:
		position_percent = position / parent.size
