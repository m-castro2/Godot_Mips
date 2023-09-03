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

var active: bool:
	set(value):
		active = value
		z_index = 1 if value else 0 # appear on top
		if target.get_parent() is MainComponent:
			target.get_parent().requested = value
		animate_line() # seems duplicate from *_detail.draw_lines but both are needed


func add_points():
	if origin == null and target == null:
		return
	
	global_position = Vector2(0, 0)
	clear_points()
	if !origin.get_point_count():
		return
	
	var start: Vector2
	var end: Vector2
	start = origin.get_point_position(0)
	add_point(start)
	end = origin.get_point_position(1)
	
	#clamp is a workaround for Add_PC, since its origin gets updated after it.
	var first_point = Vector2(start.x + clamp((end.x - start.x)*intersect_point, 7, end.x-10), start.y) 
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
	
	if get_parent() is MainComponent:
		stage = get_parent().stage_number
	else:
		stage = get_parent().get_parent().stage


func _on_Globals_expand_stage(_stage_number: int):
	visible = false
	await Globals.components_tween_finished
	await get_tree().process_frame
	
	if visibility == visibility_type.ALWAYS:
		visible = true
		return
	
	else:
		visible = (Globals.current_expanded_stage == stage)
		return


func animate_line() -> void:
	line_color = get_parent().get_parent().stage_color
	var tween: Tween = get_tree().create_tween()
	material.set("shader_parameter/color", line_color)
	tween.tween_property(self, "material:shader_parameter/draw_max", 0.0, .001)
	tween.tween_property(self, "material:shader_parameter/draw_max", 1.0, .5)
