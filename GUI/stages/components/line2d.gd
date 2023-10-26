extends Line2D
class_name Line


@export var origin: Marker2D:
	set(value):
#		if origin:
#			origin.marker_updated.disconnect(_on_marker_updated)
		origin = value
#		origin.marker_updated.connect(_on_marker_updated)

@export var target: Marker2D:
	set(value):
#		if target:
#				target.marker_updated.disconnect(_on_marker_updated)
		target = value
#		target.marker_updated.connect(_on_marker_updated)

@export var steps: int = 2

@export var middle_offset: int = 0

var draw_requested: bool = false
enum visibility_type { ALWAYS, EXPANDED}
@export var visibility: visibility_type

var stage: Globals.STAGES

var min_initial_length: int = 10
var min_finish_length: int = 10

@onready var line_color: Color = get_parent().get_parent().stage_color:
	set(value):
		line_color = value
		material.set("shader_parameter/color", line_color)

@export var force_up: bool # force to be drawn up instead of down

@export var force_backwards: bool # needed for FU output


var active: bool :
	set(value):
		active = value
		if value or force_visible:
			z_index = 2 if value else 1 # grey lines arent drawn over colored lines
			if target and target.get_parent() is MainComponent:
				target.get_parent().requested = value
			if origin and origin.get_parent() is MainComponent:
				origin.get_parent().requested = value
			add_points()
			animate_line() # seems duplicate from *_detail.draw_lines but both are needed
			check_visibility(true)
		else:
			z_index = 0
			visible = false

# force visible even if not active
@export var force_visible:= false

@export var line_to_match: Line = null

func add_points():
	if !active and !force_visible:
		return
	
	if StageControl.instruction_map.size() > stage and StageControl.instruction_map[stage] == -1:
		return
	
	if origin == null or target == null:
		return
	
	clear_points()
	
	#check_visibility()
	
	global_position = Vector2.ZERO
	add_point(origin.global_position)
	
	var origin_component = origin.get_parent()
	var target_component = target.get_parent()
	
	if !origin_component.visible or !target_component.visible:
		return
	
	if origin.global_position.y == target.global_position.y:
		add_point(target.global_position)
		return
	
	if abs(origin.global_position.y - target.global_position.y) <= 5:
		# y coord mismatch mistakes
		add_point(Vector2(target.global_position.x, origin.global_position.y))
		return
	
	if force_backwards: # FU backwards lines
		var point: Vector2 = origin.global_position + Vector2(middle_offset, 0)
		add_point(point)
		if steps == 4:
			point = Vector2(point.x, target.global_position.y)
			add_point(point)
			add_point(target.global_position)
			return
		else:
			point = Vector2(point.x, point.y + (target.global_position.y - point.y)/2)
			add_point(point)
			point = Vector2(point.x + (target.global_position.x - point.x)*.65, point.y)
			add_point(point)
			point = Vector2(point.x, target.global_position.y)
			add_point(point)
			point = Vector2(target.global_position.x, target.global_position.y)
			add_point(point)
			return
	
	if (target.global_position.x - min_finish_length) < (origin.global_position.x + min_finish_length): # origin is further right than target
		var point: Vector2 = origin.global_position + Vector2(max(\
							max(min_initial_length, target.global_position.x - origin.global_position.x),\
							(get_parent().get_parent().size.x-origin.position.x)/8), 0) # why does this work for /8??
		add_point(point)
		if force_up:
			point = Vector2(point.x, (origin_component.global_position.y - (target_component.global_position.y - \
				origin_component.global_position.y - origin_component.size.y)/2))
		else:
			point = Vector2(point.x, (origin_component.global_position.y + origin_component.size.y + (target_component.global_position.y - \
				origin_component.global_position.y - origin_component.size.y)/2))
		add_point(point)
		point = Vector2(target.global_position.x - min_finish_length, point.y)
		add_point(point)
		point = Vector2(point.x, target.global_position.y)
		add_point(point)
		add_point(Vector2(target.global_position.x, point.y))
		return
	
	min_finish_length = min(10, (target_component.position.x - (origin_component.position.x + origin_component.size.x))/2)
	min_initial_length = min_finish_length
	
	if steps == 3:
		add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x),  origin.global_position.y))
	
	elif steps != 2:
		if line_to_match:
			var point:= line_to_match.get_point_position(1)
			add_point(point)
			add_point(Vector2(point.x,  target.global_position.y))
		else:
			add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x)/2 - middle_offset,  origin.global_position.y))
			add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x)/2 - middle_offset,  target.global_position.y))
	
	add_point(target.global_position)


func _ready():
	Globals.current_expanded_stage_updated.connect(_on_Globals_expand_stage)
	#Globals.components_tween_finished.connect(add_points)
	#Globals.components_tween_finished.connect(animate_line)
	Globals.reset_button_pressed.connect(deactivate_line)
#	Globals.cycle_changed.connect(deactivate_line)
	StageControl.instruction_map_updated.connect(deactivate_line)
	LineManager.redraw_lines.connect(redraw_line)
	Globals.current_stage_sizes_updated.connect(_on_Globals_current_stage_sizes_updated)
	
	if get_parent() is MainComponent:
		stage = get_parent().stage_number
		pass
	else:
		stage = get_parent().get_parent().stage
	
	visible = false


func _on_Globals_expand_stage():#_stage_number: int):
	if !Globals.current_cycle and !force_visible:
		return
	visible = false
	
#	if Globals.current_expanded_stage == stage \
#			or Globals.previous_expanded_stage == stage:
#		return
	
	check_visibility(false)


func check_visibility(just_activated: bool):
	if !active and !force_visible:
		#Globals.can_click = true
		return
	
	visible = false
	if StageControl.instruction_map.size() < stage + 1:
		return
	if StageControl.instruction_map[stage] == -1:
		return
	if stage == 1 and PipelinedWrapper.stage_signals_map[1]["STALL"]: # for id lines
		return
	if !just_activated: #awaits needed to avoid visibility flickering
		pass
#		var stage_size_type: int
#		if Globals.current_expanded_stage == -1:
#			stage_size_type = 0
#		elif Globals.current_expanded_stage == stage:
#			stage_size_type = 1 if stage != 4 else 3
#		else:
#			stage_size_type = 2
		
#		var condition = abs(Globals.current_stage_sizes[stage] - Globals.tweened_stage_sizes[stage_size_type]) > 2
#		if condition:
#			Globals.can_click = true
#			return
#		if Globals.is_stage_tweening:
#			var timer:= get_tree().create_timer(0.3)
#			await timer.timeout
#		if !Globals.is_components_tween_finished:
#			var timer:= get_tree().create_timer(0.3)
#			await timer.timeout
#			await Globals.components_tween_finished # this await causes the lines not appearing sometimes
#		var timer:= get_tree().create_timer(0.3)
#		await timer.timeout
#		await get_tree().process_frame
#		Globals.can_click = true
	
	if visibility == visibility_type.ALWAYS:
#		if !Globals.is_components_tween_finished and !just_activated:
#			var timer:= get_tree().create_timer(0.3)
#			await timer.timeout
		visible = true
#		Globals.can_click = true
		return
	
	else:
#		if !Globals.is_components_tween_finished and !just_activated:
#			var timer:= get_tree().create_timer(0.3)
#			await timer.timeout
		visible = (Globals.current_expanded_stage == stage)
#		Globals.can_click = true
		return


func animate_line() -> void:
	if !points:
		return
	if !active and force_visible:
		line_color = Color.GRAY
	else:
		line_color = get_parent().get_parent().stage_color
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", line_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)


func deactivate_line() -> void:
	active = false


func redraw_line(register: int) -> void:
	return
	if active and register == (stage - 1):
		add_points()
		animate_line()
		check_visibility(true)


func _on_Globals_current_stage_sizes_updated(p_stage: int):
	return
	if p_stage != stage:
		return
	add_points()
	animate_line()
	check_visibility(false)


func _on_marker_updated():
	return
#	if !visible:
#		return
	if !points:
		return
	if origin.global_position == points[0] and target.global_position == points[points.size()-1]:
		return
	add_points()
	animate_line()
	check_visibility(false)
