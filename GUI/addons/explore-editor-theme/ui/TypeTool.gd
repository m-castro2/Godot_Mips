@tool
extends HBoxContainer

# Node references
@onready var label : Label = $Label
@onready var input : OptionButton = $Input

signal item_selected(index)

func _ready() -> void:
	input.clear()
	input.item_selected.connect(self._on_input_item_selected)

func add_text_item(value : String) -> void:
	input.add_item(value)

func get_selected_text() -> String:
	return input.get_item_text(input.selected)

func _on_input_item_selected(item_id : int) -> void:
	item_selected.emit(input.get_item_index(item_id))
