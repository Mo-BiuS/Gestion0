class_name BuildingHandler extends Node2D

@onready var buildingList=$BuildingList
@onready var buildingQueue=$BuildingQueue
@onready var roadQueue=$RoadQueue
@onready var terrain=$"../Terrain"
@onready var villagerHandler:VillagerHandler = $"../VillagerHandler"

const ROAD_COST = 1
var roadToBuild:Array[Vector2i]

signal refund(b)
signal refundRoad(gold:int)

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

func buildingConstructedAt(pos:Vector2i):
	for i in buildingQueue.get_children():
		if Vector2i(i.getPos()) == pos:
			buildingQueue.remove_child(i)
			buildingList.add_child(i)
			i.setShadow(0)

func getRoadWork()->Array[Vector2i]:
	return roadToBuild.duplicate()
func getBuildingWork()->Array[Building]:
	var queue = buildingQueue.get_children()
	var rep:Array[Building]
	for i in queue:
		if i is Building : rep.append(i)
	return rep
