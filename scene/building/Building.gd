class_name Building extends Sprite2D

@onready var sprite:Sprite2D
var allowedTerrainList:Array = []
var range = 0

var goldCost:int = 0
var woodCost:int = 0
var workCost:int = 0
var description:String = "EMPTY"
var specialBuildCondition:bool = false
var specialBuildAllowedTile:Array = []

var canHaveInhabitants:bool = false
var maxHabitants:int = 0
var allowedHabitants:int = 0
var habitantsList:Array[Colonist] = []

var canHaveWorkers:bool = false
var maxWorkers:int = 0
var allowedWorkers:int = 0
var workersList:Array[Colonist] = []

var workerTiedToBuilding = false

var woodJob = false
var storedWood = 0
var maxWoodStorage = 0
const WOOD_TIME = 5.0

func setShadow(v:int)->void:
	match v:
		0: self.modulate = Color(1,1,1,1)
		1: self.modulate = Color(1,1,1,0.5)
		2: self.modulate = Color(1,0.5,0.5,0.5)

func getPos()->Vector2:
	return Vector2i(position/32)

func setAllowedHabitants(value:int)->void:
	allowedHabitants = value
	while value < habitantsList.size():
		if workerTiedToBuilding:
			workersList.erase(habitantsList[-1])
			habitantsList[-1].workplace = null
		habitantsList[-1].house = null
		habitantsList.pop_back()
func setAllowedWorkers(value:int)->void:
	allowedWorkers = value
	while value < workersList.size():
		workersList[-1].workplace = null
		workersList.pop_back()
func addWood()->void:
	if(storedWood + 5 <= maxWoodStorage):
		storedWood+=5
func giveWork(terrain:Terrain, i:Colonist)->bool:
	var rep = false
	if (woodJob) : rep = giveWoodWork(terrain, i)
	return rep
func giveWoodWork(terrain:Terrain, i:Colonist)->bool:
	if(storedWood < maxWoodStorage):
		var housePos:Vector2i = self.position/32
		var closestForest:Vector2i = terrain.getClosestForestInArea(housePos, range)
		if(closestForest != null):
			var path:Array[Vector2i] = terrain.pathfindTo(Vector2i(i.position/32), closestForest)
			i.goGetWoodAt(path,WOOD_TIME)
			return true
		else : return false
	else : return false
