extends Line2D
class_name Line


@export var origin: Marker2D
@export var target: Marker2D
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
	
	if steps == 3:
		add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x),  origin.global_position.y))
	
	elif steps != 2:
		add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x)/2 - middle_offset,  origin.global_position.y))
		add_point(Vector2(origin.global_position.x + (target.global_position.x - origin.global_position.x)/2 - middle_offset,  target.global_position.y))
	
	add_point(target.global_position)


func _ready():
	Globals.expand_stage.connect(_on_Globals_expand_stage)
	Globals.components_tween_finished.connect(add_points)
	Globals.components_tween_finished.connect(animate_line)
	Globals.reset_button_pressed.connect(_on_Globals_reset_button_pressed)
	
	if get_parent() is MainComponent:
		stage = get_parent().stage_number
		pass
	else:
		stage = get_parent().get_parent().stage
	
	visible = false


func _on_Globals_expand_stage(_stage_number: int):
	check_visibility(false)


func check_visibility(just_activated: bool):
	visible = false
	
	if !just_activated:
		await Globals.components_tween_finished
		await get_tree().process_frame
	
	if visibility == visibility_type.ALWAYS:
		visible = true
		return
	
	else:
		visible = (Globals.current_expanded_stage == stage)
		return


func animate_line() -> void:
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", line_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)


func _on_Globals_reset_button_pressed() -> void:
	active = false
