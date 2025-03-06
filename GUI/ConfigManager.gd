extends Node

@onready var user_settings:= ConfigFile.new()
@onready var default_settings:= ConfigFile.new()

func _ready():
	var _err
	if !FileAccess.file_exists("user://user_settings.cfg"):
		_err = user_settings.load("res://cfg/default_config.cfg")
		user_settings.save("user://user_settings.cfg")
		default_settings = user_settings
	else:
		_err = user_settings.load("user://user_settings.cfg")
		_err = default_settings.load("res://cfg/default_config.cfg")
	
	if OS.has_feature("android"):
		default_settings.set_value("Settings/UI", "scaling", 1)


func update_value(section: String, param_name: String, value) -> void:
	user_settings.set_value(section, param_name, value)
	user_settings.save("user://user_settings.cfg")


func get_value(section: String, param_name: String):
	return user_settings.get_value(section, param_name, default_settings.get_value(section, param_name))
