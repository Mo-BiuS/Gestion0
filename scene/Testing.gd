extends Node2D

@onready var camera:Camera2D = $Camera
@onready var cursor:Node2D = $Cursor
@onready var hud:CanvasLayer = $HUD
@onready var buildingHandler:BuildingHandler=$BuildingHandler
@onready var villagerHandler:VillagerHandler=$VillagerHandler

enum State { IDLE, PLACING_BUILDING, PLACING_ROAD_0, PLACING_ROAD_1, DELETE_0, DELETE_1, SHOW_BUILDING_STAT }
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
		inMenu = inMenu || i.has_point(Vector2i(mousePos*camera.zoom.x)+(Vector2i(get_viewport_transform().origin)))
	
	hud.refreshColonist(villagerHandler.getIdleColonist().size(), villagerHandler.getColonist().size())
	
	match state:
		State.IDLE:
			if(Input.is_action_just_pressed("validate") && !inMenu):
				var selectBuilding:Building = buildingHandler.getBuildingAt(Vector2i(mousePos/32))
				if selectBuilding != null:
					hud.showBuilding(selectBuilding)
					state = State.SHOW_BUILDING_STAT
		State.PLACING_BUILDING:
			var b = cursor.getBuilding()
			cursor.setCanAfford(canAfford(b))
			if(Input.is_action_just_pressed("cancel")):
				cursor.setBuilding(-1)
				hud.deselectBuilding()
				state = State.IDLE
				buildingId = -1
			elif(Input.is_action_just_pressed("validate") && !inMenu):
				if canAfford(b) && cursor.isPositionValid() && buildingHandler.freeSpaceAt(Vector2i(b.position/32)):
					buildingHandler.addBuildingToQueue(buildingId, b)
					reduceCost(b)
				cursor.setBuilding(-1)
				hud.deselectBuilding()
				state = State.IDLE
				buildingId = -1
		State.PLACING_ROAD_0:
			if(Input.is_action_just_pressed("cancel")):
				hud.deselectBuilding()
				cursor.stopPlacingRoad()
				hud.showInfoBar(false)
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
				if(cursor.isRoadValid):gold = buildingHandler.addRoad(cursor.roadArray, gold)
				cursor.finishPlacingRoad()
		State.DELETE_0:
			if(Input.is_action_just_pressed("cancel")):
				hud.deselectBuilding()
				cursor.stopDeleting()
				hud.showInfoBar(false)
				state = State.IDLE
				buildingId = -1
			elif(Input.is_action_just_pressed("validate") && !inMenu):
				state = State.DELETE_1
				cursor.startDeleting()
		State.DELETE_1:
			if(Input.is_action_just_pressed("cancel")):
				state = State.DELETE_0
				cursor.stopDeleting()
			elif(Input.is_action_just_released("validate") && !inMenu):
				state = State.DELETE_0
				cursor.finishDeleting()
				buildingHandler.setDeleting(cursor.deletingArray)
		State.SHOW_BUILDING_STAT:
			if(!inMenu && (Input.is_action_just_pressed("validate") || Input.is_action_just_pressed("cancel") )):
				state = State.IDLE
				hud.hideBuilding()
			
func canAfford(b)->bool:
	return b.goldCost <= gold && b.woodCost <= wood

func reduceCost(b)->void:
	gold-=b.goldCost
	wood-=b.woodCost

func refundCost(b)->void:
	gold+=b.goldCost
	wood+=b.woodCost
func refundHalfCost(b)->void:
	gold+=b.goldCost/2
	wood+=b.woodCost/2

func _on_hud_buidlding_selected(toogled, id):
	if(toogled):
		if(id == 0):
			state = State.PLACING_ROAD_0
			hud.setInfoBarToRoad()
			hud.showInfoBar(true)
		elif(id == 100):
			state = State.DELETE_0
			hud.setInfoBarToDelete()
			hud.showInfoBar(true)
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


func _on_building_handler_refund_destroyed_building(b):
	refundHalfCost(b)
