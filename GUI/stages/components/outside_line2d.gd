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
		if value:
			z_index = 1
			if target.get_parent() is MainComponent:
				target.get_parent().requested = value
			add_points()
			animate_line() # seems duplicate from *_detail.draw_lines but both are needed
			check_visibility(true, false)
		else:
			z_index = 0
			visible = false

var line_color: Color

func add_points():
	if origin == null or target == null:
		return
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
	Globals.components_tween_finished.connect(add_points)
	Globals.components_tween_finished.connect(animate_line)
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	Globals.reset_button_pressed.connect(deactivate_line)
	Globals.cycle_changed.connect(deactivate_line)
	
	if origin_component:
		origin_component.visibility_changed.connect(_on_component_visibility_changed)
	if target_component:
		target_component.visibility_changed.connect(_on_component_visibility_changed)


func _on_component_visibility_changed():
	if Globals.is_stage_tweening:
		return
	
	var vis:= true
	if origin_component:
		vis = vis and origin_component.visible
	if target_component:
		vis = vis and target_component.visible
	visible = vis


func _on_Globals_expand_stage(_stage_number: int):
	if !active:
		return
	add_points()
	animate_line()
	check_visibility(false, true)


func check_visibility(just_activated: bool, just_expanded: bool) -> void:
	visible = false
	
	if just_expanded:
		await Globals.current_expanded_stage_updated
	
	if Globals.current_expanded_stage != origin_stage and Globals.current_expanded_stage != target_stage:
		return
	
	if !just_activated:
		if Globals.is_stage_tweening:
			await Globals.components_tween_finished
		await get_tree().process_frame
	
	if origin_component:
		origin_component.requested = true
	if target_component:
		target_component.requested = true
	
	_on_component_visibility_changed()
	


func set_outside_component(component: Button, which: String):
	if which == "origin":
		origin.global_position = component.global_position
	else:
		target.global_position = component.global_position


func animate_line() -> void:
	line_color = get_parent().get_parent().stage_color
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", line_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)


func _on_update_stage_colors(colors_map, instructions_map) -> void:
	if !StageControl.color_system:
		line_color = StageControl.colors[origin_stage]
		
	else:
		if !colors_map.size():
			line_color = Color.TRANSPARENT
		elif instructions_map[origin_stage] == -1 or instructions_map.size()-1 < origin_stage:
			line_color = Color.TRANSPARENT
		else:
			line_color = get_parent().get_parent().stage_color
	material.set("shader_parameter/color", line_color)


func deactivate_line() -> void:
	active = false
