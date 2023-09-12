class_name VillagerHandler extends Node2D

@onready var villagerList:Node2D = $VillagerList
@onready var buildingHandler:BuildingHandler = $"../BuildingHandler"
@onready var terrain:Terrain = $"../Terrain"
@onready var cursor = $"../Cursor"

var ongoingRoadWork:Array[Vector2i] = []
var ongoingBuildingWork:Array[Vector2i] = []
var ongoingDeleteRoadWork:Array[Vector2i] = []
var ongoingDeleteBuildingWork:Array[Building] = []

func _ready():
	for c in villagerList.get_children():
		c.roadConstructedAt.connect(roadConstructedAt)
		c.buildingConstructedAt.connect(buildingConstructedAt)
		c.roadDeletedAt.connect(roadDeletedAt)
		c.buildingDeletedAt.connect(buildingDeletedAt)

func _process(delta):
	assignWorkplaceToColonist()
	
	var idleColonist:Array[Colonist] = getIdleColonist()
	assignWorkplaceWork(idleColonist)
	assignRoadWork(idleColonist)
	assignBuildingWork(idleColonist)
	assignDeletingBuildingWork(idleColonist)
	assignDeletingRoadWork(idleColonist)
	idleReturnHome(idleColonist)
	
	assignHomeToHomeless()


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

func assignDeletingRoadWork(idleColonist:Array[Colonist])->void:
	if(!idleColonist.is_empty()):
		var roadWork:Array[Vector2i] = buildingHandler.getDeletingRoadWork()
		for i in ongoingDeleteRoadWork:
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
				colonist.goDeleteRoadAt(path, 5)
				ongoingDeleteRoadWork.push_back(Vector2i(closestRoad))
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

func assignDeletingBuildingWork(idleColonist:Array[Colonist])->void:
	if(!idleColonist.is_empty()):
		var buildingWork:Array[Building] = buildingHandler.getDeletingBuildingWork()
		for i in ongoingDeleteBuildingWork:
			for j in buildingWork:
				if i == j:
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
				colonist.goDeleteBuildingAt(path, closestBuilding.workCost)
				ongoingDeleteBuildingWork.push_back(closestBuilding)
				buildingWork.erase(closestBuilding)
				idleColonist.erase(colonist)

func roadConstructedAt(pos:Vector2i):
	buildingHandler.roadConstructedAt(pos)
	terrain.roadConstructedAt(pos)
	ongoingRoadWork.erase(pos)
	cursor.refreshPointerPos()
func roadDeletedAt(pos:Vector2i):
	buildingHandler.roadDeletedAt(pos)
	terrain.roadDeletedAt(pos)
	ongoingDeleteRoadWork.erase(pos)
	cursor.refreshPointerPos()
func buildingConstructedAt(pos:Vector2i):
	buildingHandler.buildingConstructedAt(pos)
	ongoingBuildingWork.erase(pos)
func buildingDeletedAt(pos:Vector2i):
	var b:Building = buildingHandler.buildingDeletedAt(pos)
	if b != null:
		if b.canHaveInhabitants && b.habitantsList.size() > 0:
			for i in b.habitantsList:
				i.house = null
				b.habitantsList.erase(i)
		ongoingDeleteBuildingWork.erase(b)
	cursor.refreshPointerPos()

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

func getColonist()->Array[Colonist]:
	var rep:Array[Colonist] = []
	for i in villagerList.get_children():
		if i is Colonist:rep.push_back(i)
	return rep

func cancelDeleteBuildingAt(building:Building)->void:
	if ongoingDeleteBuildingWork.has(building):
		ongoingDeleteBuildingWork.erase(building)
		for v in villagerList.get_children():
			if ((v.stateAfterMoving == v.s.DELETING_BUILDING && !v.pathTo.is_empty() && v.pathTo[-1] == Vector2i(building.getPos())) || (v.state == v.s.DELETING_BUILDING && Vector2i(v.position/32) == Vector2i(building.getPos()))):
				v.stateAfterMoving = v.s.IDLE
				v.state = v.s.IDLE
				v.buildingProgress.hide()
				v.stop()
func cancelDeleteRoadAt(pos:Vector2i)->void:
	if ongoingDeleteRoadWork.has(pos):
		ongoingDeleteRoadWork.erase(pos)
		for v in villagerList.get_children():
			if ((v.stateAfterMoving == v.s.DELETING_ROAD && !v.pathTo.is_empty() && v.pathTo[-1] == pos) || (v.state == v.s.DELETING_ROAD && Vector2i(v.position/32) == pos)):
				v.stateAfterMoving = v.s.IDLE
				v.state = v.s.IDLE
				v.buildingProgress.hide()
				v.stop()

func idleReturnHome(idleColonist:Array[Colonist])->void:
	if(!idleColonist.is_empty()):
		for i in idleColonist:
			if i.house != null && Vector2i(i.position/32) != Vector2i(i.house.getPos()):
				i.pathTo = terrain.pathfindTo(i.position/32, i.house.getPos())
				i.state = i.s.MOVING
				i.stateAfterMoving = i.s.IDLE
				idleColonist.erase(i)

func assignHomeToHomeless()->void:
	var homelessList:Array[Colonist]=[]
	for i in villagerList.get_children():
		if (i is Colonist && i.house == null):
				homelessList.push_back(i)
	if !homelessList.is_empty():
		var freeHome:Array[Building] = buildingHandler.getFreeHome()
		for building in freeHome:
			if !homelessList.is_empty():
				var path:Array[Vector2i] = terrain.pathfindTo(homelessList[0].position/32, building.getPos())
				if !path.is_empty():
					building.habitantsList.push_back(homelessList[0])
					homelessList[0].house = building
					homelessList.pop_front()
func assignWorkplaceToColonist()->void:
	var joblessList:Array[Colonist]
	for i in villagerList.get_children():
		if (i is Colonist && i.workplace == null):
				joblessList.push_back(i)
	if(!joblessList.is_empty()):
		var buildingWithJob:Array[Building] = buildingHandler.getBuildingWithJob()
		for building in buildingWithJob:
			if !joblessList.is_empty():
				var path:Array[Vector2i] = terrain.pathfindTo(joblessList[0].position/32, building.getPos())
				if(!path.is_empty() && (!building.workerTiedToBuilding || (building.workerTiedToBuilding && building.habitantsList.has(joblessList[0])))):
					building.workersList.push_back(joblessList[0])
					joblessList[0].workplace = building
					joblessList.pop_front()
	
func assignWorkplaceWork(idleColonist:Array[Colonist])->void:
	for i in idleColonist:
		if i.workplace != null:
			if(i.workplace.giveWork(terrain, i)):idleColonist.erase(i)
