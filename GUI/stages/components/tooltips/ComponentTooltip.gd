extends Control

enum ComponentTypes {REGBANK, DATAMEM}
@export var component_type: ComponentTypes
@export var line_labels: Array[LineLabel]
@export var panels: Array[PanelContainer]
@export var positions: Array[Marker2D]
@export var names: Array[String]
@onready var labels: Array[Label]

func _ready() -> void:
	if component_type == ComponentTypes.REGBANK:
		Globals.wb_to_regbank_line_activated.connect(_on_Globals_wb_to_regbank_line_activated)
	Globals.cycle_changed.connect(_on_Globals_cycle_changed)
	for i in range(0, line_labels.size()):
		line_labels[i].visibility_changed.connect(_on_line_label_visibility_changed.bind(i))
	
	setup()


func setup() -> void:
	for i in range(0, names.size()):
		var panel:= PanelContainer.new()
		var label:= Label.new()
		label.text = names[i]
		panel.add_child(label)
		add_child(panel)
		panel.position = positions[i].position - Vector2(0, label.size.y)
		panel.theme_type_variation = "BackgroundPanelContainer"
		panels.push_back(panel)
		labels.push_back(label)
		panel.visible = false


func show_tooltip():
	for i in range(0, names.size()):
		panels[i].position = positions[i].position - Vector2(0, panels[i].size.y/2)
		panels[i].size = panels[i].custom_minimum_size
	visible = true


func _on_line_label_visibility_changed(index: int) -> void:
	panels[index].visible = line_labels[index].visible


func _on_Globals_wb_to_regbank_line_activated() -> void:
	panels[5].visible = true
	panels[6].visible = true


func _on_Globals_cycle_changed() -> void:
	for panel in panels:
		panel.hide()
