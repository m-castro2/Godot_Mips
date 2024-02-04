# GdUnit generated TestSuite
class_name MipsSimTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

func test_asm1_id_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000019", "00000018", "00000017", "00000016",\
					"10010010", "00000015", "00000014", "00000013", "00000012",\
					"10010020", "00000011", "00000010", "0000000f", "0000000e",\
					"10010030", "0000000d", "0000000c", "0000000b", "0000000a",\
					"10010040", "00000009", "00000008", "00000007", "00000006",\
					"10010050", "00000005", "00000004", "00000003", "00000002",\
					"10010060", "00000001"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010064", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 182
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm1.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm1_id_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000019", "00000018", "00000017", "00000016",\
					"10010010", "00000015", "00000014", "00000013", "00000012",\
					"10010020", "00000011", "00000010", "0000000f", "0000000e",\
					"10010030", "0000000d", "0000000c", "0000000b", "0000000a",\
					"10010040", "00000009", "00000008", "00000007", "00000006",\
					"10010050", "00000005", "00000004", "00000003", "00000002",\
					"10010060", "00000001"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010064", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 182
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm1.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm1_mem_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000019", "00000018", "00000017", "00000016",\
					"10010010", "00000015", "00000014", "00000013", "00000012",\
					"10010020", "00000011", "00000010", "0000000f", "0000000e",\
					"10010030", "0000000d", "0000000c", "0000000b", "0000000a",\
					"10010040", "00000009", "00000008", "00000007", "00000006",\
					"10010050", "00000005", "00000004", "00000003", "00000002",\
					"10010060", "00000001"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010064", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 205
	
	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm1.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm1_mem_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000019", "00000000", "00000000", "00000000",\
					"10010010", "00000000", "00000000", "00000000", "00000000",\
					"10010020", "00000000", "00000000", "00000000", "00000000",\
					"10010030", "00000000", "00000000", "00000000", "00000000",\
					"10010040", "00000000", "00000000", "00000000", "00000000",\
					"10010050", "00000000", "00000000", "00000000", "00000000",\
					"10010060", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010004", "00000000", "00000000", "00000000",\
		"00000018", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 13
	
	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm1.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm2() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000019", "00000000", "10010008", "00000000",\
					"10010010", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010008", "00000000", "00000000", "00000000",\
		"00000018", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 14
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm2.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm3_id_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000010", "00000005", "00000001", "00000014",\
					"10010010", "00000004"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010010", "00000000", "00000000", "00000000",\
		"00000014", "00000000", "00000028", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 43
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm3.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm3_id_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000010", "00000005", "00000001", "00000014",\
					"10010010", "00000004"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010010", "00000000", "00000000", "00000000",\
		"00000014", "00000000", "00000028", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 43
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm3.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm3_mem_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000010", "00000005", "00000001", "00000014",\
					"10010010", "00000004"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010010", "00000000", "00000000", "00000000",\
		"00000014", "00000000", "00000028", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 49
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm3.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm3_mem_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000010", "00000005", "00000001", "00000014",\
					"10010010", "00000004"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010004", "00000003", "00000000", "00000000",\
		"00000010", "00000000", "00000020", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 19
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm3.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm4_id_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000003", "00000002", "00000001", "00000000",\
					"10010010", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "1001000c", "00000000", "00000000", "00000000",\
		"00000000", "00400010", "00000000", "00000000", "00000003", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "0040002c"]
	var expected_cycles:= 56
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm4.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm4_id_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000003", "00000002", "00000001", "00000000",\
					"10010010", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "1001000c", "00000000", "00000000", "00000000",\
		"00000000", "00400010", "00000000", "00000000", "00000003", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "0040002c"]
	var expected_cycles:= 44
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm4.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm4_mem_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000003", "00000002", "00000001", "00000000",\
					"10010010", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "1001000c", "00000000", "00000000", "00000000",\
		"00000000", "00400010", "00000000", "00000000", "00000003", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "0040002c"]
	var expected_cycles:= 50
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm4.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm4_mem_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000003", "00000002", "00000001", "00000000",\
					"10010010", "ffffffff", "fffffffe", "fffffffd", "fffffffc"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010020", "00000000", "00000000", "00000000",\
		"fffffffb", "00400010", "00000000", "00000000", "00000008", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "0040002c"]
	var expected_cycles:= 72
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm4.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)

# asm5 memory data isnt displayed correctly in MipsSim
# since only the integer part of the number is considered
func test_asm5_id_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000008", "00000000", "00000000", "00000000",\
					"10010010", "40900000", "3f000000", "40d00000", "40000000",
					"10010020", "40c66666", "3f800000", "40c66666", "40900000",
					"10010030", "00000000", "00000000", "00000000", "00000000",
					"10010040", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010030", "00000000", "10010050", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 84
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm5.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm5_id_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 0)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000008", "00000000", "00000000", "00000000",\
					"10010010", "40900000", "3f000000", "40d00000", "40000000",
					"10010020", "40c66666", "3f800000", "40c66666", "40900000",
					"10010030", "00000000", "00000000", "00000000", "00000000",
					"10010040", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010030", "00000000", "10010050", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 84
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm5.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm5_mem_non_taken() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 0)
	
	var expected_mem:= ["10010000", "00000008", "00000000", "00000000", "00000000",\
					"10010010", "40900000", "3f000000", "40d00000", "40000000",
					"10010020", "40c66666", "3f800000", "40c66666", "40900000",
					"10010030", "00000000", "00000000", "00000000", "00000000",
					"10010040", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010030", "00000000", "10010050", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 82
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm5.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)


func test_asm5_mem_delayed() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	ConfigManager.update_value("Settings/CPU", "branch_stage", 1)
	ConfigManager.update_value("Settings/CPU", "branch_type", 1)
	
	var expected_mem:= ["10010000", "00000008", "00000000", "00000000", "00000000",\
					"10010010", "40900000", "3f000000", "40d00000", "40000000",
					"10010020", "40c66666", "3f800000", "40c66666", "40900000",
					"10010030", "00000000", "00000000", "00000000", "00000000",
					"10010040", "00000000", "00000000", "00000000", "00000000"]
	var expected_registers:= [
		"00000000", "00000000", "0000000a", "00000000", "10010014", "00000007", "10010034", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",\
		"00000000", "00000000", "00000000", "00000000", "00000000", "80000000", "00000000", "00000000"]
	var expected_cycles:= 19
	

	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/asm5.s")
	runner.invoke("_on_run_program_pressed")
	var mem:= PipelinedWrapper.get_memory_data(false)
	var registers:= PipelinedWrapper.get_register_values()
	var hex_regs: Array[String]
	for reg in registers:
		hex_regs.append(PipelinedWrapper.to_hex32(reg))
	
	assert_array(mem).is_equal(expected_mem)
	assert_array(hex_regs).is_equal(expected_registers)
	assert_int(Globals.current_cycle).is_equal(expected_cycles)
