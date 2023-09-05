extends Node2D

@onready var camera:Camera2D = $Camera
@onready var cursor:Node2D = $Cursor
@onready var hud:CanvasLayer = $HUD
@onready var buildingHanlder:BuildingHandler=$BuildingHandler

enum State { IDLE, PLACING_BUILDING, PLACING_ROAD_0, PLACING_ROAD_1 }
var state:State = State.IDLE

var buildingId:int = -1

var gold = 240
var wood = 360

func _process(delta):
	hud.setGold(gold)
	hud.setWood(wood)
	
	var inMenu:bool = false
	var mousePos:Vector2i = get_local_mouse_position()
	for i in hud.getMenuArea():
		inMenu = inMenu || i.has_point(mousePos*2+(Vector2i(get_viewport_transform().origin)))
	
	match state:
		State.IDLE:pass
		State.PLACING_BUILDING:
			var b = cursor.getBuilding()
			cursor.setCanAfford(canAfford(b))
			if(Input.is_action_just_pressed("cancel")):
				cursor.setBuilding(-1)
				hud.deselectBuilding()
				state = State.IDLE
				buildingId = -1
			elif(Input.is_action_just_pressed("validate") && !inMenu):
				if canAfford(b) && cursor.isPositionValid() && buildingHanlder.freeSpaceAt(Vector2i(b.position/32)):
					buildingHanlder.addBuildingToQueue(buildingId, b)
					reduceCost(b)
				cursor.setBuilding(-1)
				hud.deselectBuilding()
				state = State.IDLE
				buildingId = -1
		State.PLACING_ROAD_0:
			if(Input.is_action_just_pressed("cancel")):
				hud.deselectBuilding()
				cursor.stopPlacingRoad()
				state = State.IDLE
				buildingId = -1
			elif(Input.is_action_just_pressed("validate") && !inMenu):
				state = State.PLACING_ROAD_1
				cursor.startPlacingRoad()
		State.PLACING_ROAD_1:
			if(Input.is_action_just_pressed("cancel")):
				state = State.PLACING_ROAD_0
				cursor.stopPlacingRoad()
			elif(Input.is_action_just_released("validate") && !inMenu):
				state = State.PLACING_ROAD_0
				if(cursor.isRoadValid):gold = buildingHanlder.addRoad(cursor.roadArray, gold)
				cursor.finishPlacingRoad()

func canAfford(b)->bool:
	return b.goldCost <= gold && b.woodCost <= wood

func reduceCost(b)->void:
	gold-=b.goldCost
	wood-=b.woodCost

func refundCost(b)->void:
	gold+=b.goldCost
	wood+=b.woodCost

func _on_hud_buidlding_selected(toogled, id):
	if(toogled):
		if(id == 0):
			state = State.PLACING_ROAD_0
		else:
			buildingId = id
			cursor.setBuilding(id)
			state = State.PLACING_BUILDING
			hud.showInfoBar(true)
			hud.setBuildingInfo(cursor.getBuilding())
	elif id == buildingId:
		buildingId = -1
		cursor.setBuilding(-1)
		state = State.IDLE
		hud.showInfoBar(false)


func _on_building_handler_refund(b):
	refundCost(b)
func _on_building_handler_refund_road(gold):
	self.gold += gold
