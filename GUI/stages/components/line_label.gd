class_name LineLabel
extends Label

@export var label_line_vertex: int
@export var label_orientation: bool = false
@export var label_padding:= Vector2(5,0)
@export var line: Line2D
@export var stage: int

@export var map_key: String
@export var map_stage: int
@export var is_register_name: bool = true


func _ready():
	line.draw.connect(_on_line_drawn)
	line.visibility_changed.connect(_on_line_visibility_changed)
	
	if label_orientation:
		rotation_degrees = 270


func _on_line_drawn():
	if line.get_point_count() < (label_line_vertex):
		return
	global_position = line.get_point_position(label_line_vertex) + label_padding - Vector2(0, size.y)


func _on_line_visibility_changed():
	visible = line.visible and Globals.current_expanded_stage == stage
	if !visible:
		return
	if is_register_name:
		text = LineManager.register_names[PipelinedWrapper.stage_signals_map[map_stage][map_key]]
	else:
		text = PipelinedWrapper.to_hex32(PipelinedWrapper.stage_signals_map[map_stage][map_key])
