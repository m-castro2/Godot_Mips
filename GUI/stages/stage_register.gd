extends Panel
class_name StageRegister

@export var register_type: LineManager.Register_Type

@export var has_block: Array[bool]
@export var text: String
@onready var register = $StageRegister/VBoxContainer/Register
@onready var outputs: Dictionary

#Input markers
@onready var pc = $StageRegister/VBoxContainer/Register/PC
@onready var rs_data = $StageRegister/VBoxContainer/Register/RsData
@onready var rt_data = $StageRegister/VBoxContainer/Register/RtData
@onready var imm_value = $StageRegister/VBoxContainer/Register/ImmValue
@onready var rs = $StageRegister/VBoxContainer/Register/Rs
@onready var rt = $StageRegister/VBoxContainer/Register/Rt
@onready var reg_dst = $StageRegister/VBoxContainer/Register/RegDst
@onready var rel_branch = $StageRegister/VBoxContainer/Register/RelBranch
#Output markers
@onready var pc_2 = $StageRegister/VBoxContainer/Register/PC2
@onready var rs_data_2 = $StageRegister/VBoxContainer/Register/RsData2
@onready var rt_data_2 = $StageRegister/VBoxContainer/Register/RtData2
@onready var imm_value_2 = $StageRegister/VBoxContainer/Register/ImmValue2
@onready var rs_2 = $StageRegister/VBoxContainer/Register/Rs2
@onready var rt_2 = $StageRegister/VBoxContainer/Register/Rt2
@onready var reg_dst_2 = $StageRegister/VBoxContainer/Register/RegDst2
@onready var rel_branch_2 = $StageRegister/VBoxContainer/Register/RelBranch2

#window
@onready var info_window: Window = $SegReg_info_window

var ready_finished: bool

var input_markers: Array[Marker2D]
var output_markers: Array[Marker2D]
var markers_resolution: Vector2i

func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	for i in range(0, $StageRegister/VBoxContainer.get_child_count() -1):
		$StageRegister/VBoxContainer.get_child(i).visible = has_block[i] 
	register.text = text.replace("\\n", "\n")
	
	var dict: Dictionary = {}
	dict["value"] = 4000
	outputs["PC"] = dict.duplicate()
	ready_finished = true
	
	LineManager.add_stage_register_path(get_path())
	info_window.seg_reg_index = register_type


func get_data():
	pass


func _on_expand_stage(_stage: int) -> void:
	pass #needed to be overriden


func update_input_output_markers() -> void:
	pass


func _on_resized():
	await LineManager.if_stage_updated
	pc.global_position.y = LineManager.get_stage_component(0, "pc").get_node("IFID_UpperInput").global_position.y
	pc_2.global_position = pc.global_position + Vector2(31, 0)
	
	rel_branch.global_position.y = register.global_position.y + register.size.y * 0.1
	rel_branch_2.global_position = rel_branch.global_position + Vector2(31, 0)
	
	rs_data.global_position.y = register.global_position.y + register.size.y * 0.25
	rs_data_2.global_position = rs_data.global_position + Vector2(31, 0)
	
	rt_data.global_position.y = register.global_position.y + register.size.y * 0.5
	rt_data_2.global_position = rt_data.global_position + Vector2(31, 0)
	
	imm_value.global_position.y = register.global_position.y + register.size.y * 0.6
	imm_value_2.global_position = imm_value.global_position + Vector2(31, 0)
	
	rs.global_position.y = register.global_position.y + register.size.y * 0.7
	rs_2.global_position = rs.global_position + Vector2(31, 0)
	
	rt.global_position.y = register.global_position.y + register.size.y * 0.75
	rt_2.global_position = rt.global_position + Vector2(31, 0)
	
	reg_dst.global_position.y = register.global_position.y + register.size.y * 0.97
	reg_dst_2.global_position = reg_dst.global_position + Vector2(31, 0)
	
	LineManager.stage_register_updated.emit(register_type)


func _on_register_item_rect_changed():
	LineManager.redraw_lines.emit(int(register_type))


func _on_v_box_container_item_rect_changed():
	LineManager.redraw_lines.emit(int(register_type))


func _on_register_pressed():
	info_window.add_info()


func _on_seg_reg_info_window_focus_exited():
	info_window.visible = false


@onready var tooltip_group = $StageRegister/VBoxContainer/Register/TooltipGroup
func _on_register_mouse_entered():
	var active_fields_names = $SegReg_info_window.get_active_fields()
	var fields_position: Array = [[], []]
	for field in active_fields_names[0]:
		var value = match_names(field)
		fields_position[0].append([get(value).global_position, field])
	for field in active_fields_names[1]:
		var value = match_names(field)
		fields_position[1].append([get(value + "_2").global_position, field])
	tooltip_group.configure(fields_position)
	tooltip_group.show()


func _on_register_mouse_exited():
	tooltip_group.hide_panels()


func match_names(field_name: String) -> String:
	match field_name:
		"Instruction":
			return "rt_data"
		"ALUOut":
			return "rt_data" if register_type == 2 else "rt"
		"MemOut":
			return "rt_data"
		"RegDest":
			return "reg_dst"
		_:
			return field_name.to_snake_case()
