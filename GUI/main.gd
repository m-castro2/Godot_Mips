extends Control

var program_loaded: bool = false

@onready
var pipelinedWrapper: PipelinedWrapper = $PipelinedWrapper

func _ready():
	Globals.load_program_pressed.connect(self._on_load_program_pressed)
	_setup_cpu_info()


func _setup_cpu_info():
	# add labels for special registers
	var labels_text = ["Special Registers", "PC", "HI", "LO"]
	for i in 4: #number of special registers so far + title
		var label: Label = Label.new()
		label.text = labels_text[i]
		%SpecialRegistersVBoxContainer.add_child(label)
	
	# add labels for registers
	labels_text = ["Integer Registers", "Single Precision FP Registers", "Double Precision FP Registers"]
	var labels: Array[Label] = []
	for i in 3: #number of register types
		var label: Label = Label.new()
		label.text = labels_text[i]
		labels.append(label)
	%IntegerRegistersVBoxContainer.add_child(labels[0])
	%FloatRegistersVBoxContainer.add_child(labels[1])
	%DoubleRegistersVBoxContainer.add_child(labels[2])
	
	for i in 32:
		var label: Label = Label.new()
		label.name = str(i)
		var label2: Label = Label.new()
		label2.name = str(i)
		
		%IntegerRegistersVBoxContainer.add_child(label)
		%FloatRegistersVBoxContainer.add_child(label2)
		
		if i < 16:
			label = Label.new()
			label.name = str(i)
			%DoubleRegistersVBoxContainer.add_child(label)



func update_cpu_info():
	#special registers labels
	(%SpecialRegistersVBoxContainer.get_child(1) as Label).text = "PC: " + pipelinedWrapper.cpu_info["PCValue"]
	(%SpecialRegistersVBoxContainer.get_child(2) as Label).text = "HI: " + pipelinedWrapper.cpu_info["HIValue"]
	(%SpecialRegistersVBoxContainer.get_child(3) as Label).text = "LO: " + pipelinedWrapper.cpu_info["LOValue"]
	
	#registers
	for i in 32:
		#add 1 because of title row
		(%IntegerRegistersVBoxContainer.get_child(i+1) as Label).text = pipelinedWrapper.cpu_info["Registers"]["iRegisters"][i]
		(%FloatRegistersVBoxContainer.get_child(i+1) as Label).text = pipelinedWrapper.cpu_info["Registers"]["fRegisters"][i]
		
		if i < 16:
			(%DoubleRegistersVBoxContainer.get_child(i+1) as Label).text = pipelinedWrapper.cpu_info["Registers"]["dRegisters"][i]


func _on_load_program_pressed():
	pipelinedWrapper.free()
	pipelinedWrapper = PipelinedWrapper.new()
	pipelinedWrapper.name = "PipelinedWrapper"
	self.add_child(pipelinedWrapper)
	program_loaded = pipelinedWrapper.load_program("res://testdata/asm1.s")
	if program_loaded and pipelinedWrapper.is_ready():
		%NextCycle.disabled = false
		%RunProgram.disabled = false
		%PreviousCycle.disabled = false
		%ShowMemory.disabled = false
		%Reset.disabled = false
	update_cpu_info()


func _on_next_cycle_pressed():
	pipelinedWrapper.next_cycle()
	update_cpu_info()


func _on_run_program_pressed():
	while pipelinedWrapper.is_ready():
		pipelinedWrapper.next_cycle()
	update_cpu_info()


func _on_reset_pressed():
	pipelinedWrapper.reset_cpu()
	update_cpu_info()


func _on_previous_cycle_pressed():
	pipelinedWrapper.previous_cycle()
	update_cpu_info()


func _on_show_memory_pressed():
	pipelinedWrapper.show_memory()
