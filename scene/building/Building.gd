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
		habitantsList.pop_back()
