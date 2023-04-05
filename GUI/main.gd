extends Control


func _on_load_program_pressed():
	print($PipelinedWrapper.load_program("/home/mike/Desktop/SharedFolder/TFG/mips_sim/testdata/asm1.s"))


func _on_next_cycle_pressed():
	$PipelinedWrapper.run_cycle()
