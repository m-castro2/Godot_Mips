extends MainComponent

#@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0)

@onready var alu_svg: String = FileAccess.get_file_as_string("res://80x150_negro-default.svg")

func _ready():
	Globals.alu_update_svg.connect(_on_Globals_alu_update_svg)
	super._ready()


func _on_Globals_alu_update_svg(viewport_size: Vector2) -> void:
	var new_scale = (viewport_size / custom_minimum_size) / (Globals.base_viewport_size / custom_minimum_size)
	var image:= Image.new()
	image.load_svg_from_string(alu_svg, min(new_scale.x, new_scale.y))
	set("texture_normal", ImageTexture.create_from_image(image))
	size = viewport_size / (Globals.base_viewport_size / custom_minimum_size)
