extends Camera2D

@onready var terrain:Terrain = $"../Terrain"

const SPEED = 400
const BORDER_SIZE = 32

const ZOOM_MIN = Vector2(1,1)
const ZOOM_MAX = Vector2(3,3)
const ZOOM_SPEED = Vector2(1,1)

func _physics_process(delta):
	if Input.is_action_pressed("move_north"):
		var limit = getNorthLimit()
		if(limit <= self.position.y-SPEED*delta):
			self.position.y-=SPEED*delta/self.zoom.y
		else: self.position.y = limit
	if Input.is_action_pressed("move_south"):
		var limit = getSouthLimit()
		if(limit >= self.position.y+SPEED*delta):
			self.position.y+=SPEED*delta/self.zoom.y
		else: self.position.y = limit
	if Input.is_action_pressed("move_west"):
		var limit = getWestLimit()
		if(limit <= self.position.x-SPEED*delta):
			self.position.x-=SPEED*delta/self.zoom.x
		else: self.position.x = limit
	if Input.is_action_pressed("move_east"):
		var limit = getEastLimit()
		if(limit >= self.position.x+SPEED*delta):
			self.position.x+=SPEED*delta/self.zoom.x
		else: self.position.x = limit
	if Input.is_action_pressed("zoom_out"):
		if(self.zoom-ZOOM_SPEED*delta > ZOOM_MIN):
			self.zoom-=ZOOM_SPEED*delta
		else:
			self.zoom = ZOOM_MIN
		keepCameraIn()
	if Input.is_action_pressed("zoom_in"):
		if(self.zoom+ZOOM_SPEED*delta < ZOOM_MAX):
			self.zoom+=ZOOM_SPEED*delta
		else:
			self.zoom = ZOOM_MAX
		keepCameraIn()

func getNorthLimit()->float:
	var terrainSize:Rect2i = terrain.getMapSize()
	return terrainSize.position.y-BORDER_SIZE*2+get_viewport().get_visible_rect().size.y/2/self.zoom.y
func getSouthLimit()->float:
	var terrainSize:Rect2i = terrain.getMapSize()
	return terrainSize.position.y+terrainSize.size.y+BORDER_SIZE*2-get_viewport().get_visible_rect().size.y/2/self.zoom.y
func getWestLimit()->float:
	var terrainSize:Rect2i = terrain.getMapSize()
	return terrainSize.position.x-BORDER_SIZE*2+get_viewport().get_visible_rect().size.x/2/self.zoom.x
func getEastLimit()->float:
	var terrainSize:Rect2i = terrain.getMapSize()
	return terrainSize.position.x+terrainSize.size.x+BORDER_SIZE*2-get_viewport().get_visible_rect().size.x/2/self.zoom.x

func keepCameraIn()->void:
	var northLimit:int = getNorthLimit()
	var southLimit:int = getSouthLimit()
	if(northLimit > self.position.y):
		if(southLimit < self.position.y):
			self.position.y = (southLimit+northLimit)/2
		else:
			self.position.y = northLimit
	elif(southLimit < self.position.y):
		self.position.y = southLimit
	
	var westLimit:int = getWestLimit()
	var eastLimit:int = getEastLimit()
	if(westLimit > self.position.x):
		if(eastLimit < self.position.x):
			self.position.x = (eastLimit+westLimit)/2
		else:
			self.position.x = westLimit
	elif(eastLimit < self.position.x):
		self.position.x = eastLimit
