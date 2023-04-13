extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready():
	var popup: PopupMenu = self.get_popup()
	popup.id_pressed.connect(self._on_popup_id_pressed)
	
	popup.add_item("Load file") #id 0


func _on_popup_id_pressed(id: int):
	if id == 0:
		Globals.load_program_pressed.emit()
