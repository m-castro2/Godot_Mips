extends Button

@onready var parent: Node = get_parent()
@export var position_percent: Vector2

func _ready():
	parent.resized.connect(_on_parent_resized)


func _on_parent_resized() -> void:
	global_position.x = parent.global_position.x + parent.size.x*position_percent.x - size.x
	global_position.y = parent.global_position.y + parent.size.y*position_percent.y - size.y/2
