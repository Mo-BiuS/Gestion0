extends Node2D

@onready var terrain:Terrain = $"../Terrain"
@onready var buildingHandler:BuildingHandler = $"../BuildingHandler"
@onready var roadShadow:TileMap = $RoadShadow

const REFRESH_TIMER=0.05
var timer:float = 0.0

var selectSize:int = 1
var buildingId:int = -1
var building:Node2D = Node2D.new()
var mousePosition:Vector2i = Vector2i(0,0)

var canAfford:bool = true

var roadStart:Vector2i
var roadEnd:Vector2i
var roadArray:Array[Vector2i]
var isRoadValid:bool

var deletingStart:Vector2i
var deletingEnd:Vector2i
var deletingArray:Array[Vector2i]

func _process(delta):
	var nMousePos:Vector2i =  Vector2i(get_global_mouse_position())/32
	if(mousePosition != nMousePos):
		refreshPointerPos()
		if building is SmallPort:
			var n:int = terrain.get_cell_source_id(1,nMousePos-Vector2i(0,-1))
			var s:int = terrain.get_cell_source_id(1,nMousePos-Vector2i(0,1))
			var e:int = terrain.get_cell_source_id(1,nMousePos-Vector2i(1,0))
			var w:int = terrain.get_cell_source_id(1,nMousePos-Vector2i(-1,0))
			building.setRotationFromTileId(n,s,e,w)

func setCanAfford(b:bool)->void:
	canAfford = b

func getBuilding():
	return building
func refreshPointerPos()->void: 
	mousePosition = (get_global_mouse_position())/32
	if(buildingId == -1):terrain.selectAt(mousePosition,selectSize)
	elif(buildingId == 0):
		handleRoadShadow()
	elif (buildingId == 100):
		handleDeletingShadow()
	else:
		building.position = mousePosition*32-Vector2i(self.position)+Vector2i(16,16)
		if(isPositionValid()):
			terrain.selectAt(mousePosition,building.range)
			building.setShadow(1)
		else:
			terrain.selectAt(mousePosition,0,true)
			building.setShadow(2)


func isPositionValid()->bool:
	var pos:Vector2i = Vector2i(building.position/32)
	return !specialPositionCheck() && canAfford && !terrain.inForest(pos)  && building.allowedTerrainList.has(terrain.get_cell_source_id(1,pos)) && buildingHandler.freeSpaceAt(pos)

func specialPositionCheck()->bool:
	if(building.specialBuildCondition):
		return !building.specialBuildAllowedTile.has(terrain.get_cell_atlas_coords(1,building.position/32))
	else:
		return false

func startPlacingRoad()->void:
	buildingId = 0
	roadStart = Vector2i(get_global_mouse_position())/32
	refreshPointerPos()
	roadEnd = roadStart
func stopPlacingRoad()->void:
	buildingId = -1
	refreshPointerPos()
	roadShadow.clear_layer(0)
func finishPlacingRoad()->void:
	buildingId = -1
	refreshPointerPos()
	roadShadow.clear_layer(0)
func getRoadArea()->Array[Vector2i]:
	var a:Array[Vector2i] = []
	if(abs(roadStart.x-roadEnd.x) > abs(roadStart.y-roadEnd.y)):
		for x in range(min(roadStart.x, roadEnd.x),max(roadStart.x, roadEnd.x)+1) : a.push_back(Vector2i(x,roadStart.y))
		for y in range(min(roadStart.y, roadEnd.y),max(roadStart.y, roadEnd.y)+1) : a.push_back(Vector2i(roadEnd.x,y))
	else:
		for y in range(min(roadStart.y, roadEnd.y),max(roadStart.y, roadEnd.y)+1) : a.push_back(Vector2i(roadStart.x,y))
		for x in range(min(roadStart.x, roadEnd.x),max(roadStart.x, roadEnd.x)+1) : a.push_back(Vector2i(x,roadEnd.y))
	return a
func handleRoadShadow()->void:
	roadEnd = Vector2i(get_global_mouse_position())/32
	roadArray = getRoadArea()
	isRoadValid = true
	for i in roadArray:
		if terrain.get_cell_source_id(1,i) != 1 || terrain.inForest(i) : isRoadValid = false
	
	if isRoadValid:
		roadShadow.set_layer_modulate(0,Color(1,1,1,0.5))
		terrain.setSelection(roadArray)
	else:
		roadShadow.set_layer_modulate(0,Color(1,0.5,0.5,0.5))
		terrain.setSelection(roadArray, true)
	
	roadShadow.clear_layer(0)
	roadShadow.set_cells_terrain_connect(0,roadArray,0,0)

#=============================================

func startDeleting()->void:
	buildingId = 100
	deletingStart = Vector2i(get_global_mouse_position())/32
	deletingEnd = deletingStart
	refreshPointerPos()
func stopDeleting()->void:
	buildingId = -1
	refreshPointerPos()
func finishDeleting()->void:
	buildingId = -1
	refreshPointerPos()
func getDeletingArea()->Array[Vector2i]:
	var a:Array[Vector2i] = []
	for x in range(min(deletingStart.x, deletingEnd.x),max(deletingStart.x, deletingEnd.x)+1) :
		for y in range(min(deletingStart.y, deletingEnd.y),max(deletingStart.y, deletingEnd.y)+1): 
			a.push_back(Vector2i(x,y))
	return a
func handleDeletingShadow()->void:
	deletingEnd = Vector2i(get_global_mouse_position())/32
	deletingArray = getDeletingArea()
	terrain.setSelection(deletingArray, true)

#=============================================

func setBuilding(id:int)->void:
	match id :
		-1:
			buildingId = id
			building.hide()
			refreshPointerPos()
		1:
			buildingId = id
			remove_child(building)
			building = preload("res://scene/building/ColonistHouse.tscn").instantiate()
			building.setShadow(1)
			add_child(building)
			terrain.deselect()
		2:
			buildingId = id
			remove_child(building)
			building = preload("res://scene/building/ColonistStorage.tscn").instantiate()
			building.setShadow(1)
			add_child(building)
			terrain.deselect()
		3:
			buildingId = id
			remove_child(building)
			building = preload("res://scene/building/SmallPort.tscn").instantiate()
			building.setShadow(1)
			add_child(building)
			terrain.deselect()
