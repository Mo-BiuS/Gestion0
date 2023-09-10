extends CanvasLayer

@onready var deconstructTool:Button = $VBoxContainer/BuildingBar/MarginContainer/HBoxContainer/deconstruct
@onready var colonistPath:Button = $VBoxContainer/BuildingBar/MarginContainer/HBoxContainer/path
@onready var colonistHouse:Button = $VBoxContainer/BuildingBar/MarginContainer/HBoxContainer/colonisthouse
@onready var colonistStorage:Button = $VBoxContainer/BuildingBar/MarginContainer/HBoxContainer/colonistStorage
@onready var smallPort:Button = $VBoxContainer/BuildingBar/MarginContainer/HBoxContainer/smallPort

@onready var goldSum:Label = $RessourceBar/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/GoldLabel
@onready var woodSum:Label = $RessourceBar/MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/WoodLabel

@onready var goldCost:Label = $VBoxContainer/infoBar/MarginContainer/VBoxContainer/Prices/MarginContainer/HBoxContainer/GoldCost
@onready var woodCost:Label = $VBoxContainer/infoBar/MarginContainer/VBoxContainer/Prices/MarginContainer/HBoxContainer/WoodCost
@onready var workCost:Label = $VBoxContainer/infoBar/MarginContainer/VBoxContainer/Prices/MarginContainer/HBoxContainer/WorkCost
@onready var descritpion:Label = $VBoxContainer/infoBar/MarginContainer/VBoxContainer/Description/MarginContainer/HBoxContainer/Description

@onready var ressourceBar:PanelContainer = $RessourceBar
@onready var infoBar:PanelContainer = $VBoxContainer/infoBar
@onready var buildingBar:PanelContainer = $VBoxContainer/BuildingBar
@onready var lowerMenu:VBoxContainer = $VBoxContainer


signal buidldingSelected(toogled:bool, id:int)

func getMenuArea()->Array[Rect2i]:
	var menuArea:Array[Rect2i]
	menuArea.push_back(Rect2i(ressourceBar.position, ressourceBar.size))
	menuArea.push_back(Rect2i(infoBar.position+lowerMenu.position, infoBar.size))
	menuArea.push_back(Rect2i(buildingBar.position+lowerMenu.position, buildingBar.size))
	return menuArea

func deselectBuilding()->void:
	colonistPath.button_pressed = false
	colonistHouse.button_pressed = false
	colonistStorage.button_pressed = false
	smallPort.button_pressed = false
	deconstructTool.button_pressed = false

func showInfoBar(b:bool)->void:
	infoBar.visible = b

func setInfoBarToRoad()->void:
	setGoldCost(1)
	setWoodCost(0)
	setWorkCost(5)
	setDescription("Simple road")

func setInfoBarToDelete()->void:
	setGoldCost(0)
	setWoodCost(0)
	setWorkCost(0)
	setDescription("Delete road and structure")

func setBuildingInfo(b)->void:
	setGoldCost(b.goldCost)
	setWoodCost(b.woodCost)
	setWorkCost(b.workCost)
	setDescription(b.description)

func setGold(gold:int)->void:
	goldSum.text = "Gold : " + str(gold)
func setWood(wood:int)->void:
	woodSum.text = "Wood : " + str(wood)

func setGoldCost(cost:int)->void:
	if(cost > 0):
		goldCost.show()
		goldCost.text = "Gold : " + str(cost)
	else : goldCost.hide()
func setWoodCost(cost:int)->void:
	if(cost > 0):
		woodCost.show()
		woodCost.text = "Wood : " + str(cost)
	else : woodCost.hide()
func setWorkCost(cost:int)->void:
	if(cost > 0):
		workCost.show()
		workCost.text = "Work : " + str(cost)
	else : workCost.hide()
func setDescription(txt:String)->void:
	descritpion.text = txt

func _on_path_toggled(button_pressed):
	buidldingSelected.emit(button_pressed, 0)
	if(button_pressed):
		colonistHouse.button_pressed = false
		colonistStorage.button_pressed = false
		smallPort.button_pressed = false
		deconstructTool.button_pressed = false
func _on_colonisthouse_toggled(button_pressed):
	buidldingSelected.emit(button_pressed, 1)
	if(button_pressed):
		colonistPath.button_pressed = false
		colonistStorage.button_pressed = false
		smallPort.button_pressed = false
		deconstructTool.button_pressed = false
func _on_colonist_storage_toggled(button_pressed):
	buidldingSelected.emit(button_pressed, 2)
	if(button_pressed):
		colonistPath.button_pressed = false
		colonistHouse.button_pressed = false
		smallPort.button_pressed = false
		deconstructTool.button_pressed = false
func _on_small_port_toggled(button_pressed):
	buidldingSelected.emit(button_pressed, 3)
	if(button_pressed):
		colonistPath.button_pressed = false
		colonistHouse.button_pressed = false
		colonistStorage.button_pressed = false
		deconstructTool.button_pressed = false
func _on_deconstruct_toggled(button_pressed):
	buidldingSelected.emit(button_pressed, 100)
	if(button_pressed):
		colonistPath.button_pressed = false
		colonistHouse.button_pressed = false
		colonistStorage.button_pressed = false
		smallPort.button_pressed = false
