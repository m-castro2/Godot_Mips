extends Label

@onready var parent:= get_parent() as MainComponent

@onready var base_scale:= Globals.base_viewport_size / custom_minimum_size

func _ready():
	print(Globals.base_viewport_size)
	print(custom_minimum_size)
#	Globals.viewport_resized.connect(_on_Globals_viewport_resized)
	parent.resized.connect(_on_parent_resized)
#	resized.connect(_on_resized)
	theme_changed.connect(_on_resized)

func _on_Globals_viewport_resized(viewport_size: Vector2) -> void:
	var font_size: int = max(12, 1.6 * viewport_size.y / 72)
	add_theme_font_size_override("font_size",font_size)
	size = viewport_size / base_scale


func _on_parent_resized() -> void:
	position.y = parent.size.y / 7
	$Output.global_position = Vector2(global_position.x + size.x + 10, parent.global_position.y + parent.size.y * 0.329)


func _on_resized() -> void:
	var viewport_size:= Vector2(get_tree().root.size)
	var offset:= float(get_tree().root.size.x) / (Globals.base_viewport_size.x / 40)
	position.x = -offset
	position.y = parent.size.y / 7
	$Output.global_position = Vector2(global_position.x + size.x + 10, parent.global_position.y + parent.size.y * 0.329)
	size = viewport_size / base_scale
