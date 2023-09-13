class_name ColonistStorage extends Building

func _ready():
	allowedTerrainList = [1]#ground only
	range = 5
	
	goldCost = 100
	woodCost = 120
	workCost = 40
	description= "Small storage building"
	
	canHaveWorkers = true
	maxWorkers = 1
	allowedWorkers = 0
	
	isStorage = true
