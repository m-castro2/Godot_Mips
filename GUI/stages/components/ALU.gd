extends MainComponent

#@onready var pipelinedWrapper: PipelinedWrapper = get_tree().root.get_child(Globals.singleton_number).get_child(0)

#@onready var alu_svg: String = FileAccess.get_file_as_string("res://80x150_negro-default.svg")

func _ready():
	Globals.alu_update_svg.connect(_on_Globals_alu_update_svg)
	super._ready()

var alu_svg: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!-- Generator: Adobe Illustrator 28.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
	 viewBox=\"0 0 80 150\" style=\"enable-background:new 0 0 80 150;\" xml:space=\"preserve\">
<g>
	<polygon style=\"fill:#25282d;\" points=\"80,104.4313431 0,150 0,88.6705933 7.8700519,75 0,61.3294029 0,0 80,45.5686531 	\"/>
</g>
</svg>"


func _on_Globals_alu_update_svg(viewport_size: Vector2) -> void:
	var new_scale = (viewport_size / custom_minimum_size) / (Globals.base_viewport_size / custom_minimum_size)
	var image:= Image.new()
	image.load_svg_from_string(alu_svg, min(new_scale.x, new_scale.y))
	var image_tex:= ImageTexture.create_from_image(image)
	set("texture_normal", image_tex)
	set("texture_hover", image_tex)
	size = image_tex.get_size()
