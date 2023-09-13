class_name ColonistHouse extends Building

func _ready():
	allowedTerrainList = [1]#ground only
	range = 3
	
	goldCost = 0
	woodCost = 30
	workCost = 10
	description= "Small colonist house"
	
	canHaveInhabitants = true
	maxHabitants = 2
	allowedHabitants = 0
	
	canHaveWorkers = true
	maxWorkers = maxHabitants
	allowedWorkers = 0
	
	workerTiedToBuilding = true
	woodJob = true
	maxWoodStorage = 25
	woodProductionPerWork = 1
	woodProductionTimeNeeded = 5.0
