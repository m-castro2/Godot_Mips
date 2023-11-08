extends BaseButton
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

@export var component_tooltip: Control = null

#var tween: Tween = null

signal request_updated

var requested: bool = false :
	set(value):
		requested = value
		request_updated.emit(stage_number, name)


func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	Globals.cycle_changed.connect(_on_globals_cycle_changed)
	if !reference_node:
		reference_node = get_parent()
	reference_node.resized.connect(_on_parent_resized)
	request_updated.connect(_on_component_requested)
	
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)
	custom_minimum_size = size


signal position_updated
func _on_parent_resized() -> void:
#	if tween:
#		Globals.is_components_tween_finished = false
#		tween.kill()
	
	var position_modifier: Vector2 = expanded_position_percent if expanded else position_percent
	var new_position: Vector2 = Vector2.ZERO
	#tween = get_tree().create_tween()
	if expanded and alignment_mode == alignment_type.OFFSET:
		new_position.x = reference_node.size.x*position_modifier.x - size.x
		new_position.y = reference_node.size.y*position_modifier.y - size.y/2
	else:
		new_position = reference_node.size*position_modifier - size/2
	position = new_position
#	tween.tween_property(self, "position", new_position, 0.001)
	
#	if !Globals.is_stage_tweening:
	#await tween.finished
	Globals.components_tween_finished.emit()
	Globals.is_components_tween_finished = true
	position_updated.emit()


func _on_expand_stage(_stage: int):
	await Globals.current_expanded_stage_updated
	expanded = (Globals.current_expanded_stage == stage_number)
	
	if visibility == visibility_type.ALWAYS:
		_on_parent_resized()
		visible = true
		return
	
#	if expanded:
#		await Globals.stage_tween_finished 
#		_on_parent_resized()
#		visible = true
#		return
	
	if requested and (expanded or Globals.current_expanded_stage in request_stage_origin):
		_on_parent_resized()
		visible = true
		return
		
	visible = false


func _on_component_requested(stage: int, component_name: String):
	if stage == stage_number and component_name == name:
		if requested and (expanded or Globals.current_expanded_stage in request_stage_origin):
			visible = true
		else:
			visible = false if visibility == visibility_type.EXPANDED else true


func _on_globals_cycle_changed():
	if visibility != visibility_type.ALWAYS:
		visible = false
	requested = false


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	var base_scale:= Globals.base_viewport_size / custom_minimum_size
#	size = viewport_size / base_scale
	#var font_size: int = max(12, 1.6 * viewport_size.y / 72)
	#add_theme_font_size_override("font_size",font_size)
	var minimum_size_rate:= custom_minimum_size.x / custom_minimum_size.y
	var scaled_size:= viewport_size / base_scale
	var scaled_size_rate:= scaled_size.x / scaled_size.y
	
	if scaled_size_rate >= minimum_size_rate:
		scaled_size.x = scaled_size.y * minimum_size_rate
	else:
		scaled_size.y = scaled_size.x / minimum_size_rate
	size = scaled_size


func _on_mouse_entered():
	component_tooltip.show_tooltip()


func _on_mouse_exited():
	component_tooltip.hide()
