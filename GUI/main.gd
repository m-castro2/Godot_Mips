extends Control


func _on_button_pressed():
	print($GodotWrapper.init())
	print("run_cycle: \n", $GodotWrapper.run_cycle())
