extends Node2D

@onready var villagerList:Node2D = $VillagerList
@onready var buildingHandler:BuildingHandler = $"../BuildingHandler"
@onready var terrain:Terrain = $"../Terrain"

var ongoingRoadWork:Array[Vector2i] = []

func _process(delta):
	var idleColonist:Array[Colonist] = getIdleColonist()
	if(!idleColonist.is_empty()):
		assignRoadWork(idleColonist)


func assignRoadWork(idleColonist:Array[Colonist]):
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
			if path.size() > localRoadPath.size() || path.is_empty() : 
				closestRoad = road
				path = localRoadPath	
		if !path.is_empty(): #Si chemin trouvé
			colonist.goBuildAt(path, 5)
			ongoingRoadWork.push_back(Vector2i(closestRoad))
			roadWork.erase(closestRoad)


func getIdleColonist()->Array[Colonist]:
	var rep:Array[Colonist] = []
	for i in villagerList.get_children():
		if i.state == i.s.IDLE || i.state == i.s.MOVING_IDLE :
			rep.push_back(i)
	rep.shuffle()
	return rep
