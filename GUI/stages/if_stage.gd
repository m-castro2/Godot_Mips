extends Control


var expanded = false
@onready var detailedControl = $VBoxContainer/Control/DetailedControl
@onready var instructions_memory_button = $VBoxContainer/Control/InstructionsMemoryButton
@onready var mux = $VBoxContainer/Control/DetailedControl/Mux
@onready var pc = $VBoxContainer/Control/DetailedControl/PC
@onready var add = $VBoxContainer/Control/DetailedControl/Add

var lines_groups: Array[String] = ["PC_InstMem", "Mux_PC", "PC_Add", "Add_IFID", "InstMem_IFID", "Add_Mux"]

func _ready() -> void:
	StageControl.update_stage_colors.connect(_on_update_stage_colors)
	get_tree().get_root().size_changed.connect(_on_resized)


func _on_stage_button_pressed():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio", 1 if expanded else 3, 0.15)
	expanded = !expanded
	if !expanded:
		detailedControl.visible = expanded
		await tween.finished
	else:
		await tween.finished
		detailedControl.visible = expanded


func _on_instructions_memory_button_pressed():
	Globals.show_instructions_memory.emit()


func _on_update_stage_colors(colors_map, instructions):
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox.bg_color = colors_map[instructions[0]]
	$VBoxContainer/PanelContainer/StageButton.add_theme_stylebox_override("normal", styleBox)


func _on_resized():
	if expanded:
		await get_tree().process_frame #wait a frame for nodes position to be updated 
		calculate_positions()
		draw_lines()


func calculate_positions():
	var control_size: Vector2 = detailedControl.size
	
	if add: #if one is ready all are ready
		
		add.global_position = Vector2((instructions_memory_button.global_position.x + instructions_memory_button.size.x/2) - add.size.x/2, \
		(control_size.y/2 - instructions_memory_button.size.y/2)/2-add.size.y/2 + detailedControl.global_position.y )
		
		pc.position = Vector2(instructions_memory_button.position.x/2 - pc.size.x/2 + detailedControl.size.x*.05, \
		control_size.y/2 - pc.size.y/2 )
		
		mux.position = Vector2(instructions_memory_button.position.x/2 - mux.size.x/2 - detailedControl.size.x*.1, \
		control_size.y/2 - mux.size.y/2 )
		
		%IFID_UpperInput.global_position = Vector2(global_position.x + size.x, add.global_position.y + add.size.y/2)
		%IFID_MiddleInput.global_position = Vector2(global_position.x + size.x, instructions_memory_button.global_position.y + instructions_memory_button.size.y/2)


func draw_lines():
	await get_tree().process_frame
	var line: Line2D = null
	var points: Array[Vector2] = []
	for group in lines_groups:
		for node in get_tree().get_nodes_in_group(group):
			if node is ComplexLine2D:
				node.add_points()
			elif node is Line2D:
				node.clear_points()
				line = node
				line.global_position = Vector2(0,0)
			else:
				points.push_back(node.global_position)
		for point in points:
			line.add_point(point)
		points.clear()
	


func _on_minus_pressed():
	$VBoxContainer/Control.scale = $VBoxContainer/Control.scale - Vector2(.1, .1)


func _on_plus_pressed():
	$VBoxContainer/Control.scale = $VBoxContainer/Control.scale + Vector2(.1, .1)
