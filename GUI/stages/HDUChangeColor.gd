extends Node

@onready var parent: Button = get_parent()

enum HDU_STATES { OK, STALL, FORWARDED}
var current_state:= HDU_STATES.OK

func check_state():
	var instructions:= StageControl.instruction_map
	if !instructions.size() or instructions[1] == -1:
		current_state = HDU_STATES.OK
		return
	
	var map:= PipelinedWrapper.stage_signals_map
	
	if map[1]["STALL"]:
		current_state = HDU_STATES.STALL
		return
	
	if instructions[2] != -1:
		if map[2]["REG_DEST_REGISTER"] == map[1]["RS_REG"] or \
				(map[2]["REG_DEST_REGISTER"] == map[1]["RT_REG"] and map[1]["USE_RT"]):
			current_state = HDU_STATES.FORWARDED
			return
	
	if instructions[3] != -1:
		if map[3]["REG_DEST_REGISTER"] == map[1]["RS_REG"] or \
				(map[3]["REG_DEST_REGISTER"] == map[1]["RT_REG"] and map[1]["USE_RT"]):
			current_state = HDU_STATES.FORWARDED
			return
	
	current_state = HDU_STATES.OK


var default_color:= Color.hex(0x1a1a1a99)
func change_color():
	var color: Color
	match current_state:
		HDU_STATES.OK:
			color = default_color
		HDU_STATES.STALL:
			color = Color.WEB_MAROON
		HDU_STATES.FORWARDED:
			color = Color.ROYAL_BLUE
	var tween:= create_tween()
	tween.tween_property(parent, "theme_override_styles/disabled:bg_color", color, 0.25)


func _ready():
	Globals.reset_button_pressed.connect(_on_Globals_reset_pressed)
	var stylebox:= StyleBoxFlat.new()
	stylebox.bg_color = default_color
	stylebox.corner_detail = 5
	stylebox.set_corner_radius_all(3)
	parent.add_theme_stylebox_override("disabled", stylebox)


func _on_Globals_reset_pressed():
	var stylebox:= StyleBoxFlat.new()
	stylebox.bg_color = default_color
	stylebox.corner_detail = 5
	stylebox.set_corner_radius_all(3)
	parent.add_theme_stylebox_override("disabled", stylebox)
