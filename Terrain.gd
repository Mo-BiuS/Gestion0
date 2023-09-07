class_name Terrain extends TileMap

@onready var northWest:Marker2D = $NorthWest
@onready var southEast:Marker2D = $SouthEast

var rect:Rect2i=Rect2i(0,0,0,0)
var tileCost:Dictionary
var speedModifier:Dictionary
var impassableTerrain:Array

func _ready():
	impassableTerrain.push_back(4)#Sea
	impassableTerrain.push_back(5)#Montain
	tileCost[100]=0.5 #Path
	tileCost[6]=2 #Forest
	tileCost[7]=3 #DeepForest
	speedModifier[100]=2 #Path
	speedModifier[6]=0.7 #Forest
	speedModifier[7]=0.5 #DeepForest
	
	var p = northWest.position
	var l = southEast.position-northWest.position
	rect = Rect2i(p.x,p.y,l.x,l.y)

func getMapSize()->Rect2i:
	return Rect2i(northWest.position, southEast.position+northWest.position)

func deselect()->void:
	self.clear_layer(3)

func selectAt(pos:Vector2i, size:int, red:bool=false)->void:
	if(red):self.set_layer_modulate(3,Color(1,0.5,0.5,1))
	else:self.set_layer_modulate(3,Color(1,1,1,1))
	self.clear_layer(3)
	self.set_cells_terrain_connect(3,selectAtArray(pos,size),4,0)

func setSelection(a:Array[Vector2i], red:bool=false)->void:
	if(red):self.set_layer_modulate(3,Color(1,0.5,0.5,1))
	else:self.set_layer_modulate(3,Color(1,1,1,1))
	self.clear_layer(3)
	self.set_cells_terrain_connect(3,a,4,0)

func selectAtArray(pos:Vector2i,size:float):
	var pathIn:Dictionary
	pathIn[pos] = 0
	if size > 1 :
		var pathOut:Array[Vector2i] = []
		var cost:float = 0
		var valueLeft:Array[float]=[cost]
		while(!cost >= size):
			for i in pathIn.keys():
				if pathIn[i] == cost:
					var direction:Array[Vector2i] = [i+Vector2i(0,-1),i+Vector2i(0,1),i+Vector2i(1,0),i+Vector2i(-1,0)]
					direction.shuffle()
					for d in direction :
						if(isValidForColonist(d) && !pathIn.has(d)):
							var additionalCost = getTileCost(d)
							if(!valueLeft.has(cost+additionalCost)):valueLeft.append(cost+additionalCost)
							pathIn[d] = cost+additionalCost
			valueLeft.erase(cost)
			if !valueLeft.is_empty():cost = valueLeft.min()
			else: cost = size
	return pathIn.keys()
	
func unique_array(array: Array[Vector2i]) -> Array[Vector2i]:
	var unique: Array[Vector2i] = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
			
	return unique

func pathfindTo(from:Vector2i, to:Vector2i)->Array[Vector2i]:
	var pathIn:Dictionary
	var pathOut:Array[Vector2i] = []
	if isValidForColonist(from) && isValidForColonist(to):
		var cost:float = 0
		var valueLeft:Array[float]=[cost]
		pathIn[from] = cost
		while(!valueLeft.is_empty() && !pathIn.has(to)):
			for i in pathIn.keys():
				if pathIn[i] == cost:
					var direction:Array[Vector2i] = [i+Vector2i(0,-1),i+Vector2i(0,1),i+Vector2i(1,0),i+Vector2i(-1,0)]
					direction.shuffle()
					for d in direction :
						if(isValidForColonist(d) && !pathIn.has(d)):
							var additionalCost = getTileCost(d)
							if(!valueLeft.has(cost+additionalCost)):valueLeft.append(cost+additionalCost)
							pathIn[d] = cost+additionalCost
			valueLeft.erase(cost)
			if(!valueLeft.is_empty()):cost = valueLeft.min()
			else: cost = 0
		#self.clear_layer(4)
		#self.set_cells_terrain_connect(4,pathIn.keys(),4,0)
		if(pathIn.has(to)):
			pathOut.push_front(to)
			var rt:Vector2i = to
			while(!pathOut.has(from)):
				var direction:Array[Vector2i] = [rt+Vector2i(0,-1),rt+Vector2i(0,1),rt+Vector2i(1,0),rt+Vector2i(-1,0)]
				for d in direction :
					if pathIn.has(d) && pathIn[d] < cost:
						cost = pathIn[d]
						rt = d
				pathOut.push_front(rt)
	#self.clear_layer(4)
	#self.set_cells_terrain_connect(4,pathOut,4,0)
	return pathOut

func roadConstructedAt(pos:Vector2i):
	self.set_cells_terrain_connect(2,[pos],3,0)

func isValidForColonist(pos:Vector2i)->bool:
	var id = self.get_cell_source_id(1,pos)
	return id == 1 || id == 2
func getTileCost(pos:Vector2i)->float:
	var c = 1
	var tileId = self.get_cell_source_id(2,pos)
	if(tileCost.has(tileId)) : c = tileCost[tileId]
	return c
func getSpeedModifierAt(pos:Vector2i)->float:
	var c = 1
	var tileId = self.get_cell_source_id(2,pos)
	if(speedModifier.has(tileId)) : c = speedModifier[tileId]
	return c

func inForest(pos:Vector2i)->bool:
	return self.get_cell_source_id(2,pos) == 6 || self.get_cell_source_id(2,pos) == 7
