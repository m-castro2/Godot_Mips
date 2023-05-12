extends Panel

@onready var registers_bank = $RegistersBank
@onready var fp_registers_bank = $FPRegistersBank
@onready var detailed_control = $DetailedControl
@onready var add = $DetailedControl/Add
@onready var mux_control = $DetailedControl/MuxControl
@onready var mux_rt_data = $DetailedControl/MuxRtData
@onready var mux_reg_dst = $DetailedControl/MuxRegDst


func show_detail(value: bool) -> void:
	detailed_control.visible = value


func calculate_positions():
	var control_size: Vector2 = detailed_control.size
	
	if add: #if one is ready all are ready
		add.global_position = Vector2((registers_bank.global_position.x + registers_bank.size.x/2)*.925 - add.size.x/2, \
		(registers_bank.global_position.y - detailed_control.global_position.y)/2-add.size.y/2 + detailed_control.global_position.y)
			
		mux_control.position = Vector2(registers_bank.position.x/2 - mux_control.size.x/2 - detailed_control.size.x*.1, \
		control_size.y/2 - mux_control.size.y/2 )
		
		mux_rt_data.position = Vector2(registers_bank.position.x/2 - mux_rt_data.size.x/2 - detailed_control.size.x*.1, \
		control_size.y/2 - mux_rt_data.size.y/2 )
		
		mux_reg_dst.position = Vector2(registers_bank.position.x/2 - mux_reg_dst.size.x/2 - detailed_control.size.x*.1, \
		control_size.y/2 - mux_reg_dst.size.y/2 )


func draw_lines():
	pass


func _on_registers_bank_pressed():
	registers_bank.show_info_window()


func _on_fp_registers_bank_pressed():
	fp_registers_bank.show_info_window()
