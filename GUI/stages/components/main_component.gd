extends Button
class_name MainComponent

@export var reference_node: Node
@export var position_percent: Vector2

func _ready():
	get_parent().resized.connect(_on_parent_resized)


func _on_parent_resized() -> void:
	global_position.x = reference_node.global_position.x + reference_node.size.x*position_percent.x - size.x
	global_position.y = reference_node.global_position.y + reference_node.size.y*position_percent.y - size.y/2
