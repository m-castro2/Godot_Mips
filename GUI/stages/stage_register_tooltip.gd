extends Control

@onready var read_group = $ReadGroup
@onready var write_group = $WriteGroup

var seg_reg_index: int

func _ready():
	seg_reg_index = get_parent().owner.get("register_type")


func configure(field_positions: Array) -> void:
	if !field_positions[0].size() and !field_positions[1].size():
		return
	
	if Globals.current_expanded_stage == seg_reg_index:
		if field_positions[0].size():
			var prev_panel_size: float
			for i in range(0, field_positions[0].size()):
				var panel: PanelContainer = read_group.get_child(i)
				var child: Label = panel.get_child(0)
				child.text = field_positions[0][i][1].to_camel_case()
				panel.size = child.size + Vector2(21,3)
				panel.global_position = field_positions[0][i][0] - Vector2(panel.size.x, panel.size.y/2)
				if i and panel.global_position.y < prev_panel_size:
					panel.global_position.y = prev_panel_size + 1
				panel.visible = true
				prev_panel_size = panel.global_position.y + panel.size.y
	
	if Globals.current_expanded_stage == seg_reg_index +1:
		if field_positions[1].size():
			var prev_panel_size: float
			for i in range(0, field_positions[1].size()):
				var panel: PanelContainer = write_group.get_child(i)
				var child: Label = panel.get_child(0)
				child.text = field_positions[1][i][1].to_camel_case()
				panel.size = child.size + Vector2(21,3)
				panel.global_position = field_positions[1][i][0] - Vector2(0, panel.size.y/2)
				if i and panel.global_position.y < prev_panel_size:
					panel.global_position.y = prev_panel_size + 1
				panel.visible = true
				prev_panel_size = panel.global_position.y + panel.size.y

func hide_panels():
	for child in read_group.get_children():
		child.hide()
	for child in write_group.get_children():
		child.hide()

