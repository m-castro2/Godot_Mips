extends MarginContainer
class_name StageRegister

@export var has_block: Array[bool]
@export var text: String
@onready var register = $VBoxContainer/Register
@onready var outputs: Dictionary
var ready_finished: bool

var input_markers: Array[Marker2D]
var output_markers: Array[Marker2D]
var markers_resolution: Vector2i

func _ready():
	Globals.expand_stage.connect(_on_expand_stage)
	for i in range(0, $VBoxContainer.get_child_count() -1):
		$VBoxContainer.get_child(i).visible = has_block[i] 
	register.text = text.replace("\\n", "\n")
	
	var dict: Dictionary
	dict["value"] = 4000
	outputs["PC"] = dict.duplicate()
	ready_finished = true



func get_data():
	pass


func _on_expand_stage(_stage: int) -> void:
	pass #needed to be overriden


func update_input_output_markers() -> void:
	pass
