extends PanelContainer

@onready var buildingName:Label = $MarginContainer/VBoxContainer/NamePanel/MarginContainer/Name

@onready var housePanel=$MarginContainer/VBoxContainer/HousePanel
@onready var maxHabitantSlider:HSlider = $MarginContainer/VBoxContainer/HousePanel/MarginContainer/VBoxContainer/MaxHabitantSliders
@onready var residentLabel:Label = $MarginContainer/VBoxContainer/HousePanel/MarginContainer/VBoxContainer/Resident

@onready var workPanel=$MarginContainer/VBoxContainer/WorkPanel
@onready var maxWorkerSlider:HSlider = $MarginContainer/VBoxContainer/WorkPanel/MarginContainer/VBoxContainer/MaxWorker
@onready var workerLabel:Label = $MarginContainer/VBoxContainer/WorkPanel/MarginContainer/VBoxContainer/Worker


var building:Building = null

func _process(delta):
	if housePanel.is_visible_in_tree():refreshResidentLabel()
	if workPanel.is_visible_in_tree():refreshWorkerLabel()

func setData(b:Building)->void:
	building = b
	if building is ColonistHouse:
		buildingName.text = "Colonist house"
	elif building is ColonistStorage:
		buildingName.text = "Small storage"
	elif building is SmallPort:
		buildingName.text = "Small port"
	
	if building.canHaveInhabitants:
		housePanel.show()
		maxHabitantSlider.max_value = building.maxHabitants
		maxHabitantSlider.value = building.allowedHabitants
		refreshResidentLabel()
	else:
		housePanel.hide()
	
	if building.canHaveWorkers:
		workPanel.show()
		maxWorkerSlider.max_value = building.maxWorkers
		maxWorkerSlider.value = building.allowedWorkers
		refreshResidentLabel()
	else:
		workPanel.hide()

func refreshResidentLabel()->void:
	residentLabel.text = "Residents : "+str(building.habitantsList.size())+"/"+str(building.allowedHabitants)
func _on_max_habitant_sliders_drag_ended(value_changed):
	building.setAllowedHabitants(maxHabitantSlider.value)
	refreshResidentLabel()

func refreshWorkerLabel()->void:
	workerLabel.text = "Worker : "+str(building.workersList.size())+"/"+str(building.allowedWorkers)
func _on_max_worker_drag_ended(value_changed):
		building.setAllowedWorkers(maxWorkerSlider.value)
		refreshWorkerLabel()
