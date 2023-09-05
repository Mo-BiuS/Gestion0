class_name ColonistStorage extends Building

func _ready():
	allowedTerrainList = [1]#ground only
	range = 6
	
	goldCost = 100
	woodCost = 120
	workCost = 40
	description= "Small storage building"
