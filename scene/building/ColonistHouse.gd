class_name ColonistHouse extends Building

func _ready():
	allowedTerrainList = [1]#ground only
	range = 4
	
	goldCost = 0
	woodCost = 30
	workCost = 10
	description= "Small colonist house"
