extends Control


func _on_button_pressed():
	print($GodotWrapper.init())
	print("run_cycle: \n", $GodotWrapper.run_cycle())
	print($GodotWrapper.load_program("/home/mike/Desktop/Ubuntu shared folder/TFG/mips_sim/testdata/test.s"))
