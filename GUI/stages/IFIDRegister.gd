extends StageRegister

## True if a stage to which this register is connected is expanded
var detailed = false

func _ready():
	super._ready()


func _on_expand_stage(stage: int) -> void:
	if stage == 0 or stage == 1:
		detailed = !detailed
	else:
		detailed = false


func get_data():
	if register:
		outputs["position"] = Vector2(register.global_position.x, register.global_position.y + register.size.y * .1)
		return outputs
