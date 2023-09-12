class_name SmallPort extends Building

func _ready():
	allowedTerrainList = [2]#beach only
	range = 7
	
	goldCost = 160
	woodCost = 160
	workCost = 60
	description= "Small port for voyage and commerce"
	
	specialBuildCondition = true
	specialBuildAllowedTile = [Vector2i(1,2),Vector2i(2,1),Vector2i(0,1),Vector2i(1,0)]
	
	canHaveWorkers = true
	maxWorkers = 1
	allowedWorkers = 0

func setRotationFromTileId(n:int,s:int,e:int,w:int)->void:
	if(n == 1 && s == 4):region_rect.position.x = 32
	elif(n == 4 && s == 1):region_rect.position.x = 96
	elif(w == 4 && e == 1):region_rect.position.x = 64
	elif(w == 1 && e == 4):region_rect.position.x = 0
