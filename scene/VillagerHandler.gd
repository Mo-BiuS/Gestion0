extends Node2D

@onready var villagerList:Node2D = $VillagerList
@onready var buildingHandler:BuildingHandler = $"../BuildingHandler"
@onready var terrain:Terrain = $"../Terrain"

var ongoingRoadWork:Array[Vector2i]

func _process(delta):
	var idleColonist:Array[Colonist] = getIdleColonist()
	if(!idleColonist.is_empty()):
		var roadWork:Array[Vector2i] = buildingHandler.getRoadWork(ongoingRoadWork)
		while(!idleColonist.is_empty() && !roadWork.is_empty()):
			if(assignRoadWork(idleColonist[0], roadWork)):
				idleColonist.remove_at(0)

func assignRoadWork(c:Colonist, rw:Array[Vector2i])->bool:
	var cpos:Vector2 = Vector2i(c.position/32)
	var closest:Vector2 = rw[0]
	for r in rw:
		if cpos.distance_to(closest) > cpos.distance_to(r): closest = r
	var path:Array[Vector2i] = terrain.pathfindTo(cpos, closest)
	if !path.is_empty():
		c.goBuildAt(path, 5)
		ongoingRoadWork.push_back(closest)
		rw.erase(Vector2i(closest))
		return true
	else: return false

func getIdleColonist()->Array[Colonist]:
	var rep:Array[Colonist] = []
	for i in villagerList.get_children():
		if i.state == i.s.IDLE || i.state == i.s.MOVING_IDLE :
			rep.push_back(i)
	return rep
