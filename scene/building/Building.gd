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

func setShadow(v:int)->void:
	match v:
		0: self.modulate = Color(1,1,1,1)
		1: self.modulate = Color(1,1,1,0.5)
		2: self.modulate = Color(1,0.5,0.5,0.5)
