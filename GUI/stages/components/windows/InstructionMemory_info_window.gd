extends BaseWindow

@onready var v_box_container = $PanelContainer/ScrollContainer/VBoxContainer
var labels: Array[Label]

func _ready():
	base_window_scale = Globals.base_viewport_size / Vector2(min_size)
	super._ready()


func add_info():
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
	
	visible = true
	Globals.close_window_handled = false
	
	if !Globals.is_program_loaded:
		return
	
	for instruction in PipelinedWrapper.instructions:
		var label:= Label.new()
		label.text = instruction[1]
		v_box_container.add_child(label)
