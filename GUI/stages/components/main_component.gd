extends ClickableComponent
class_name MainComponent

# positioning properties
@export var reference_node: Node
@export var position_percent: Vector2
@export var expanded_position_percent: Vector2
@export var stage_number: int
enum alignment_type { OFFSET, CENTER}
@export var alignment_mode: alignment_type ## position_percent relative to
enum visibility_type { ALWAYS, EXPANDED}
@export var visibility: visibility_type
var expanded: bool = false

@export var request_stage_origin: Array[int] = []

signal request_updated

var requested: bool = false :
	set(value):
		requested = value
		request_updated.emit(stage_number, name)

func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	if !reference_node:
		reference_node = get_parent()
	reference_node.resized.connect(_on_parent_resized)
	request_updated.connect(_on_component_requested)


func _on_parent_resized() -> void:
	var position_modifier: Vector2 = expanded_position_percent if expanded else position_percent
	var tween: Tween = get_tree().create_tween()
	var new_position: Vector2 = Vector2.ZERO
	if expanded and alignment_mode == alignment_type.OFFSET:
		new_position.x = reference_node.global_position.x + reference_node.size.x*position_modifier.x - size.x
		new_position.y = reference_node.global_position.y + reference_node.size.y*position_modifier.y - size.y/2
	else:
		new_position.x = reference_node.global_position.x + reference_node.size.x*position_modifier.x - size.x/2
		new_position.y = reference_node.global_position.y + reference_node.size.y*position_modifier.y - size.y/2
	tween.tween_property(self, "global_position", new_position, 0.05)
	if !Globals.is_stage_tweening:
		await tween.finished
		Globals.components_tween_finished.emit()


func _on_expand_stage(_stage: int):
	expanded = (Globals.current_expanded_stage == stage_number)
	
	if visibility == visibility_type.ALWAYS:
		visible = true
		return
	
	if expanded:
		await Globals.stage_tween_finished 
		_on_parent_resized()
		visible = true
		return
	
	if visibility == visibility_type.EXPANDED and requested and Globals.current_expanded_stage in request_stage_origin:
		visible = true
		return
		
	visible = false


func _on_component_requested(stage: int, component_name: String):
	if stage == stage_number and component_name == name:
		if visibility == visibility_type.EXPANDED and requested and Globals.current_expanded_stage in request_stage_origin:
			visible = true
