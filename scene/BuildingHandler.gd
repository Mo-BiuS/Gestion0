class_name BuildingHandler extends Node2D

@onready var buildingList=$BuildingList
@onready var buildingQueue=$BuildingQueue
@onready var roadQueue=$RoadQueue
@onready var deleteQueue=$DeleteQueue
@onready var terrain=$"../Terrain"
@onready var villagerHandler:VillagerHandler = $"../VillagerHandler"

const ROAD_COST = 1
var roadToBuild:Array[Vector2i]
var roadToDelete:Array[Vector2i]
var buildingToDelete:Array[Building]

signal refund(b)
signal refundRoad(gold:int)
signal refundDestroyedBuilding(b)

func _process(delta):
	if Input.is_action_pressed("cancel"):
		var pos:Vector2i = get_global_mouse_position()/32
		for i in buildingQueue.get_children():
			if Vector2i(i.position/32) == pos:
				refund.emit(i)
				i.queue_free()
				villagerHandler.cancelBuildingAt(Vector2i(i.position/32))
				break
		if(roadToBuild.has(pos)):
			roadToBuild.erase(pos)
			refreshRoad()
			refundRoad.emit(ROAD_COST)
			villagerHandler.cancelRoadAt(pos)
		if(roadToDelete.has(pos)):
			roadToDelete.erase(pos)
			refreshDelete()
			villagerHandler.cancelDeleteRoadAt(pos)
		for i in buildingToDelete:
			if(Vector2i(i.getPos()) == pos):
				buildingToDelete.erase(i)
				refreshDelete()
				villagerHandler.cancelDeleteBuildingAt(i)

func freeSpaceAt(pos:Vector2i)->bool:
	var rep:bool = true
	for i in buildingList.get_children():
		if Vector2i(i.position/32) == pos:
			rep = false
			break
	if(rep):
		for i in buildingQueue.get_children():
			if Vector2i(i.position/32) == pos:
				rep = false
				break
	return rep

func addBuildingToQueue(buildingId, buildStat)->void:
	var building = null
	match buildingId:
		1:building = preload("res://scene/building/ColonistHouse.tscn").instantiate()
		2:building = preload("res://scene/building/ColonistStorage.tscn").instantiate()
		3:building = preload("res://scene/building/SmallPort.tscn").instantiate()
	if(building != null):
		building.setShadow(1)
		building.position = buildStat.position
		building.region_rect = buildStat.region_rect
		buildingQueue.add_child(building)


func addRoad(roadToAdd:Array[Vector2i], budget:int)->int:
	for i in roadToAdd:
		if budget >= ROAD_COST && !roadToBuild.has(i) && !terrain.get_cell_source_id(2,i) == 100 :
			roadToBuild.push_back(i)
			budget-=ROAD_COST
	refreshRoad()
	return budget

func refreshRoad()->void:
	roadQueue.clear_layer(0)
	roadQueue.set_cells_terrain_connect(0,roadToBuild,0,0)

func roadConstructedAt(pos:Vector2i):
	roadToBuild.erase(pos)
	refreshRoad()
func roadDeletedAt(pos:Vector2i):
	roadToDelete.erase(pos)
	refreshDelete()
func buildingConstructedAt(pos:Vector2i):
	for i in buildingQueue.get_children():
		if Vector2i(i.getPos()) == pos:
			buildingQueue.remove_child(i)
			buildingList.add_child(i)
			i.setShadow(0)
func buildingDeletedAt(pos:Vector2i)->Building:
	for i in buildingList.get_children():
		if Vector2i(i.getPos()) == pos:
			buildingToDelete.erase(i)
			buildingList.remove_child(i)
			refundDestroyedBuilding.emit(i)
			refreshDelete()
			return i
	return null


func getRoadWork()->Array[Vector2i]:
	return roadToBuild.duplicate()
func getBuildingWork()->Array[Building]:
	var queue = buildingQueue.get_children()
	var rep:Array[Building]
	for i in queue:
		if i is Building : rep.append(i)
	return rep
func getDeletingRoadWork()->Array[Vector2i]:
	return roadToDelete.duplicate()
func getDeletingBuildingWork()->Array[Building]:
	return buildingToDelete.duplicate()

func setDeleting(deleteAtPos:Array[Vector2i])->void:
	for pos in deleteAtPos:
		var buildingDeleted = false
		for building in buildingList.get_children():
			if(Vector2i(building.getPos()) == pos):
				if(buildingToDelete.is_empty()):
					buildingToDelete.push_back(building)
					buildingDeleted = true
				else:
					for i in buildingToDelete:
						if !Vector2i(i.getPos()) == pos:
							buildingToDelete.push_back(building)
							buildingDeleted = true
		if(!buildingDeleted && terrain.roadAt(pos) && !roadToDelete.has(pos)):
			roadToDelete.push_back(pos)
	refreshDelete()

func refreshDelete()->void:
	deleteQueue.clear_layer(0)
	var pos:Array[Vector2i]
	for i in buildingToDelete:
		pos.push_back(Vector2i(i.getPos()))
	deleteQueue.set_cells_terrain_connect(0,pos,0,0)
	deleteQueue.set_cells_terrain_connect(0,roadToDelete,0,0)

func getBuildingAt(pos:Vector2i)->Building:
	for b in buildingList.get_children():
		if b is Building && Vector2i(b.getPos()) == pos:
			return b
	return null

func getFreeHome()->Array[Building]:
	var rep:Array[Building] = []
	for i in buildingList.get_children():
		if i is Building && i.canHaveInhabitants && i.habitantsList.size() < i.allowedHabitants:
			rep.push_back(i)
	return rep
