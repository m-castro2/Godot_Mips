extends Line2D

class_name ComplexLine2D

@export var origin: Line2D
@export var target: Marker2D
@export var intersect_point: float

## true if the line goes from right to left
@export var flag: bool
@export var offset: Vector2
@export var width_percent: float

var draw_requested: bool = false
enum visibility_type { ALWAYS, EXPANDED}
@export var visibility: visibility_type

var stage: Globals.STAGES

var line_color: Color

var active: bool :
	set(value):
		active = value
		if value:
			z_index = 1
			if target.get_parent() is MainComponent:
				target.get_parent().requested = value
			add_points()
			animate_line() # seems duplicate from *_detail.draw_lines but both are needed
			check_visibility(true)
		else:
			z_index = 0
			visible = false


func add_points():
	if !active:
		return
	
	if origin == null and target == null:
		return
	
	global_position = Vector2(0, 0)
	clear_points()
	if !origin.get_point_count():
		return
	
	var start: Vector2
	var end: Vector2
	origin.add_points() #force update line positions
	if origin.get_point_count() < 2:
		return
	
	if origin is ComplexLine2D:
		start = origin.get_point_position(2)
		end = origin.get_point_position(3)
	else:
		start = origin.get_point_position(0)
		end = origin.get_point_position(1)
	
	add_point(start)
	
	var first_point = Vector2(start.x + (end.x - start.x)*intersect_point, start.y) 
	add_point(first_point)
	if flag:
		add_point(Vector2(first_point.x, start.y - offset.y))
		add_point(Vector2(target.global_position.x - offset.x, start.y - offset.y))
		add_point(Vector2(target.global_position.x - offset.x, target.global_position.y))
	else:
		add_point(Vector2(first_point.x, target.global_position.y))
	add_point(target.global_position)
	


func _ready():
	Globals.expand_stage.connect(_on_Globals_expand_stage)
	Globals.components_tween_finished.connect(add_points)
	Globals.components_tween_finished.connect(animate_line)
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	Globals.cycle_changed.connect(deactivate_line)
	Globals.reset_button_pressed.connect(deactivate_line)
	LineManager.redraw_lines.connect(redraw_line)
	
	if get_parent() is MainComponent:
		stage = get_parent().stage_number
	else:
		stage = get_parent().get_parent().stage
	
	visible = false
	active = false


func _on_Globals_expand_stage(_stage_number: int):
	if !active:
		return
	add_points()
	animate_line()
	check_visibility(false)


func check_visibility(just_activated: bool):
	if !active:
		return
	
	visible = false
	
	if !just_activated:
		await Globals.components_tween_finished
		await get_tree().process_frame
	
	if visibility == visibility_type.ALWAYS:
		visible = true
	
	else:
		visible = (Globals.current_expanded_stage == stage)


func animate_line() -> void:
	line_color = get_parent().get_parent().stage_color
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", line_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)


func _on_update_stage_colors(colors_map, instructions_map) -> void:
	if !StageControl.color_system:
		line_color = StageControl.colors[stage]
		
	else:
		if !colors_map.size():
			line_color = Color.BLACK
		elif instructions_map[stage] == -1:
			line_color = Color.BLACK
		else:
			line_color = get_parent().get_parent().stage_color
	material.set("shader_parameter/color", line_color)


func deactivate_line():
	active = false


func redraw_line(register: int) -> void:
	if active and register == (stage - 1):
		add_points()
		animate_line()
		check_visibility(true)
