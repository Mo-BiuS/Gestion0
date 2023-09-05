class_name Terrain extends TileMap

@onready var northWest:Marker2D = $NorthWest
@onready var southEast:Marker2D = $SouthEast

var rect:Rect2i=Rect2i(0,0,0,0)
var tileCost:Dictionary
var impassableTerrain:Array

func _ready():
	impassableTerrain.push_back(4)#Sea
	impassableTerrain.push_back(5)#Montain
	tileCost[100]=0.25 #Path
	tileCost[6]=2 #Forest
	tileCost[7]=3 #DeepForest
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

func selectAtArray(pos:Vector2i,size:float)->Array[Vector2i]:
	
	if rect.has_point(pos*32):
		var rep:Array[Vector2i] = [pos]
		var posId = self.get_cell_source_id(2,pos)
		if(tileCost.has(posId)):size-=tileCost[posId]
		else : size-=1
		if size > 1 && !impassableTerrain.has(get_cell_source_id(1,pos)):
			rep.append_array(selectAtArray(pos-Vector2i(-1,0),size))
			rep.append_array(selectAtArray(pos-Vector2i(1,0),size))
			rep.append_array(selectAtArray(pos-Vector2i(0,-1),size))
			rep.append_array(selectAtArray(pos-Vector2i(0,1),size))
		return unique_array(rep)
	else : return []
	
func unique_array(array: Array[Vector2i]) -> Array[Vector2i]:
	var unique: Array[Vector2i] = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique
