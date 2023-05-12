extends ClickableComponent
class_name MainComponent

@export var reference_node: Node
@export var position_percent: Vector2
@export var expanded_position_percent: Vector2
@export var stage_number: int
enum alignment_type { ENDX, CENTERXY}
@export var alignment_mode: alignment_type ## position_percent relative to
var expanded: bool = false

func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	reference_node.resized.connect(_on_parent_resized)


func _on_parent_resized() -> void:
	var position_modifier: Vector2 = expanded_position_percent if expanded else position_percent
	if expanded and alignment_mode == alignment_type.ENDX:
		global_position.x = reference_node.global_position.x + reference_node.size.x*position_modifier.x - size.x
		global_position.y = reference_node.global_position.y + reference_node.size.y*position_modifier.y - size.y/2
	else:
		global_position.x = reference_node.global_position.x + reference_node.size.x*position_modifier.x - size.x/2
		global_position.y = reference_node.global_position.y + reference_node.size.y*position_modifier.y - size.y/2


func _on_expand_stage(stage: int):
	expanded = (stage == stage_number)
