extends ScrollContainer


@onready var special_registers_v_box_container: VBoxContainer = %SpecialRegistersVBoxContainer
@onready var integer_registers_v_box_container: VBoxContainer = %IntegerRegistersVBoxContainer
@onready var float_registers_v_box_container: VBoxContainer = %FloatRegistersVBoxContainer
@onready var double_registers_v_box_container: VBoxContainer = %DoubleRegistersVBoxContainer


func _ready():
	setup_cpu_info()

func setup_cpu_info():
	# add labels for special registers
	var labels_text = ["Special Registers", "PC", "HI", "LO"]
	for i in 4: #number of special registers so far + title
		var label: Label = Label.new()
		label.text = labels_text[i]
		special_registers_v_box_container.add_child(label)
	
	# add labels for registers
	labels_text = ["Integer Registers", "Single Precision FP Registers", "Double Precision FP Registers"]
	var labels: Array[Label] = []
	for i in 3: #number of register types
		var label: Label = Label.new()
		label.text = labels_text[i]
		labels.append(label)
	integer_registers_v_box_container.add_child(labels[0])
	float_registers_v_box_container.add_child(labels[1])
	double_registers_v_box_container.add_child(labels[2])
	
	for i in 32:
		var label: Label = Label.new()
		label.name = str(i)
		var label2: Label = Label.new()
		label2.name = str(i)
		
		integer_registers_v_box_container.add_child(label)
		float_registers_v_box_container.add_child(label2)
		
		if i < 16:
			label = Label.new()
			label.name = str(i)
			double_registers_v_box_container.add_child(label)

func update_cpu_info(p_cpu_info: Dictionary):
	#special registers labels
	(special_registers_v_box_container.get_child(1) as Label).text = "PC: " + p_cpu_info["PCValue"]
	(special_registers_v_box_container.get_child(2) as Label).text = "HI: " + p_cpu_info["HIValue"]
	(special_registers_v_box_container.get_child(3) as Label).text = "LO: " + p_cpu_info["LOValue"]
	
	#registers
	for i in 32:
		#add 1 because of title row
		(integer_registers_v_box_container.get_child(i+1) as Label).text = p_cpu_info["Registers"]["iRegisters"][i]
		(float_registers_v_box_container.get_child(i+1) as Label).text = p_cpu_info["Registers"]["fRegisters"][i]
		
		if i < 16:
			(double_registers_v_box_container.get_child(i+1) as Label).text = p_cpu_info["Registers"]["dRegisters"][i]
