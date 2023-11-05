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

@export var label_to_substitute: LineLabel = null

@export var to_hex: bool = true

@export var use_special_text: bool
@export var special_text: String = "STALL"

var scaling:= 1

func _ready():
	line.draw.connect(_on_line_drawn)
	line.visibility_changed.connect(_on_line_visibility_changed)
	
	if label_orientation:
		rotation_degrees = 90
	
	if label_to_substitute:
		label_to_substitute.visibility_changed.connect(_on_line_to_substitute_visibility_changed)
	
	Globals.viewport_resized.connect(_on_Globals_viewport_resized)
	visible = false
	size = custom_minimum_size


func _on_line_drawn():
	if line.get_point_count() < label_line_vertex:
		return
	global_position = line.get_point_position(label_line_vertex) + label_padding * scaling - Vector2(0, size.y)


func _on_line_visibility_changed():
	if label_to_substitute and label_to_substitute.visible:
		visible = false
		return
	if !line.active:
		visible = false
		return
	visible = line.visible and Globals.current_expanded_stage == stage
	if !visible:
		return
	if is_register_name:
		text = LineManager.register_names[PipelinedWrapper.stage_signals_map[map_stage][map_key]]
	elif to_hex:
		text = PipelinedWrapper.to_hex32(PipelinedWrapper.stage_signals_map[map_stage][map_key])
	else:
		text = str(PipelinedWrapper.stage_signals_map[map_stage][map_key])
	if use_special_text:
		text = special_text


func _on_line_to_substitute_visibility_changed() -> void:
	if label_to_substitute.visible:
		visible = false


func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	scaling = max(viewport_size.y / Globals.base_viewport_size.y, 1)
	size = custom_minimum_size
	#_on_line_visibility_changed()
