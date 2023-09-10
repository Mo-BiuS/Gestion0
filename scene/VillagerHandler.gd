class_name VillagerHandler extends Node2D

@onready var villagerList:Node2D = $VillagerList
@onready var buildingHandler:BuildingHandler = $"../BuildingHandler"
@onready var terrain:Terrain = $"../Terrain"
@onready var cursor = $"../Cursor"

var ongoingRoadWork:Array[Vector2i] = []
var ongoingBuildingWork:Array[Vector2i] = []

func _ready():
	for c in villagerList.get_children():
		c.roadConstructedAt.connect(roadConstructedAt)
		c.buildingConstructedAt.connect(buildingConstructedAt)

func _process(delta):
	var idleColonist:Array[Colonist] = getIdleColonist()
	assignRoadWork(idleColonist)
	assignBuildingWork(idleColonist)


func assignRoadWork(idleColonist:Array[Colonist])->void:
	if(!idleColonist.is_empty()):
		var roadWork:Array[Vector2i] = buildingHandler.getRoadWork()
		for i in ongoingRoadWork:
			roadWork.erase(i)
		
		if(!roadWork.is_empty()):
			#pour chaque glandeur
			var colonist:Colonist = idleColonist[0]
			var colonistPos:Vector2 = Vector2i(colonist.position/32)
			var closestRoad:Vector2 = Vector2(roadWork[0])
			var path:Array[Vector2i] = terrain.pathfindTo(colonistPos, closestRoad)
				
			#Calcul route la plus proche
			for road in roadWork:
				var localRoadPath:Array[Vector2i] = terrain.pathfindTo(colonistPos, road)
				if ((path.size() > localRoadPath.size() && !localRoadPath.is_empty())) || path.is_empty() : 
					closestRoad = road
					path = localRoadPath	
			if !path.is_empty() && !path.has(Vector2i(0,0)): #Si chemin trouvé
				colonist.goBuildRoadAt(path, 5)
				ongoingRoadWork.push_back(Vector2i(closestRoad))
				roadWork.erase(closestRoad)
				idleColonist.erase(colonist)

func assignBuildingWork(idleColonist:Array[Colonist])->void:
	if(!idleColonist.is_empty()):
		var buildingWork:Array[Building] = buildingHandler.getBuildingWork()
		for i in ongoingBuildingWork:
			for j in buildingWork:
				if i == Vector2i(j.getPos()):
					buildingWork.erase(j)
		
		if !buildingWork.is_empty():
			var colonist:Colonist = idleColonist[0]
			var colonistPos:Vector2 = Vector2i(colonist.position/32)
			var closestBuilding:Building = buildingWork[0]
			var path:Array[Vector2i] = terrain.pathfindTo(colonistPos, closestBuilding.getPos())
				
			#Calcul route la plus proche
			for building in buildingWork:
				var localBuildPath:Array[Vector2i] = terrain.pathfindTo(colonistPos, building.getPos())
				if ((path.size() > localBuildPath.size() && !localBuildPath.is_empty())) || path.is_empty() : 
					closestBuilding = building
					path = localBuildPath	
			if !path.is_empty() && !path.has(Vector2i(0,0)): #Si chemin trouvé
				colonist.goBuildAt(path, closestBuilding.workCost)
				ongoingBuildingWork.push_back(Vector2i(closestBuilding.getPos()))
				buildingWork.erase(closestBuilding)
				idleColonist.erase(colonist)

func roadConstructedAt(pos:Vector2i):
	buildingHandler.roadConstructedAt(pos)
	terrain.roadConstructedAt(pos)
	ongoingRoadWork.erase(pos)
	cursor.refreshPointerPos()
func buildingConstructedAt(pos:Vector2i):
	buildingHandler.buildingConstructedAt(pos)
	ongoingBuildingWork.erase(pos)

func cancelRoadAt(pos:Vector2i):
	if ongoingRoadWork.has(pos):
		ongoingRoadWork.erase(pos)
		for v in villagerList.get_children():
			if ((v.stateAfterMoving == v.s.BUILDING_ROAD && !v.pathTo.is_empty() && v.pathTo[-1] == pos) || (v.state == v.s.BUILDING_ROAD && Vector2i(v.position/32) == pos)):
				v.stateAfterMoving = v.s.IDLE
				v.state = v.s.IDLE
				v.buildingProgress.hide()
				v.stop()

func cancelBuildingAt(pos:Vector2i):
	if ongoingBuildingWork.has(pos):
		ongoingBuildingWork.erase(pos)
		for v in villagerList.get_children():
			if ((v.stateAfterMoving == v.s.BUILDING_BUILDING && !v.pathTo.is_empty() && v.pathTo[-1] == pos) || (v.state == v.s.BUILDING_BUILDING && Vector2i(v.position/32) == pos)):
				
				v.stateAfterMoving = v.s.IDLE
				v.state = v.s.IDLE
				v.buildingProgress.hide()
				v.stop()

func getIdleColonist()->Array[Colonist]:
	var rep:Array[Colonist] = []
	for i in villagerList.get_children():
		if i.state == i.s.IDLE || i.state == i.s.MOVING_IDLE :
			rep.push_back(i)
	rep.shuffle()
	return rep
