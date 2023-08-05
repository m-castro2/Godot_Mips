extends Line2D

class_name OutsideLine2D

@export var origin_component: MainComponent
@export var origin: Marker2D
var target: Marker2D
var target_component: MainComponent
@export var intersect_point: float

## true if the line's height doesn't need ajdustment to not be drawn over other components
@export var flag: bool
@export_range(0, 1) var height_percent: float

@export var offset: int

# 0 input is from the left side of the button, 1 from the right
@export var left_right_input: bool = 0


@export var min_initial_length: int = 10
@export var min_finish_length: int = 10

@export var origin_stage: Globals.STAGES
@export var target_stage: Globals.STAGES

var active: bool :
	set(value):
		active = value
		z_index = 1 if value else 0
		animate_line(get_parent().get_parent().stage_color)


func add_points():
	global_position = Vector2(0, 0)
	clear_points()
	add_point(origin.global_position)
	if flag:
		add_point(Vector2(target.global_position.x - offset, origin.global_position.y))
		add_point(Vector2(target.global_position.x - offset, target.global_position.y))
	else:
		var parent_position: float = get_parent().global_position.y
		var parent_height: float = get_parent().size.y
		add_point(origin.global_position + Vector2(min_initial_length, 0)) # force to start drawing to the right
		add_point(Vector2(origin.global_position.x + min_initial_length, parent_position + parent_height * height_percent)) # continue to height percent point
		if left_right_input:
			add_point(Vector2(target.global_position.x + min_finish_length, parent_position + parent_height * height_percent)) # go further left than target point
			add_point(Vector2(target.global_position.x + min_finish_length, target.global_position.y)) # come back to target height
		else:
			add_point(Vector2(target.global_position.x - min_finish_length, parent_position + parent_height * height_percent)) # go further left than target point
			add_point(Vector2(target.global_position.x - min_finish_length, target.global_position.y)) # come back to target height
	
	add_point(target.global_position)


func _ready():
	Globals.expand_stage.connect(_on_Globals_expand_stage)


func _on_Globals_expand_stage(_stage_number: int):
	visible = false
	await Globals.current_expanded_stage_updated
	
	if Globals.current_expanded_stage != origin_stage and Globals.current_expanded_stage != target_stage:
		return
		
	await Globals.components_tween_finished
	await get_tree().process_frame
	visible = true
	
	if origin_component:
		origin_component.requested = true
	if target_component:
		target_component.requested = true


func set_outside_component(component: Button, which: String):
	if which == "origin":
		origin.global_position = component.global_position
	else:
		target.global_position = component.global_position


func animate_line(stage_color: Color) -> void:
	await Globals.components_tween_finished
	await get_tree().process_frame
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", stage_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)
