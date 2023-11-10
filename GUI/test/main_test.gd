# GdUnit generated TestSuite
class_name MainTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://main.gd'


func test_single_precision() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/testFPU3.s")
	runner.invoke("_on_run_program_pressed")
	
	var fp_as_float = PipelinedWrapper.get_fp_register_values_f()
	# simple
	assert_float(fp_as_float[0]).is_equal(4.5)
	assert_float(fp_as_float[2]).is_equal(9.)
	assert_float(fp_as_float[4]).is_equal(40.5)
	assert_float(fp_as_float[6]).is_equal(9.)
	assert_float(fp_as_float[8]).is_equal(4.5)
	assert_float(fp_as_float[10]).is_equal(9.)


func test_double_precision() -> void:
	LineManager.stage_detail_path.clear()
	LineManager.stage_register_path.clear()
	var runner := scene_runner("res://main.tscn")
	runner.invoke("_on_load_program_pressed", "testdata/testFPU2.s")
	runner.invoke("_on_run_program_pressed")
	var fp_as_double = PipelinedWrapper.get_fp_register_values_d() # d registers return 16 values
	# double
	assert_float(fp_as_double[0 / 2]).is_equal(4.5)
	assert_float(fp_as_double[2 / 2]).is_equal(9.)
	assert_float(fp_as_double[4 / 2]).is_equal(40.5)
	assert_float(fp_as_double[6 / 2]).is_equal(9.)
	assert_float(fp_as_double[8 / 2]).is_equal(4.5)
