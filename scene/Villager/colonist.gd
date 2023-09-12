class_name Colonist extends AnimatedSprite2D

@onready var terrain = $"../../../Terrain"
@onready var buildingProgress:ProgressBar = $ProgressBar

enum s { IDLE , MOVING_IDLE, MOVING, BUILDING_ROAD, BUILDING_BUILDING, DELETING_ROAD, DELETING_BUILDING, COLLECTING_WOOD, DEPOSING_WOOD }
var state = s.IDLE
var stateAfterMoving = s.IDLE

const MIN_WAITING:float = 0.5
const MAX_WAITING:float = 1.5
var waiting:float = randf_range(MIN_WAITING,MAX_WAITING)

const MIN_CASE_POS = 2
const SPEED = 12.0
var speedModifier = 1.0
var odlPos:Vector2i = Vector2i(position/32)
var nextCasePos:Vector2
var pathTo:Array[Vector2i] = []
var pathToReturnHome:Array[Vector2i] = []
var buildTime:float = 0

var house:Building = null
var workplace:Building = null

signal roadConstructedAt(pos:Vector2i)
signal roadDeletedAt(pos:Vector2i)
signal buildingConstructedAt(pos:Vector2i)
signal buildingDeletedAt(pos:Vector2i)


func _ready():
	var pos:Vector2i = Vector2i(position/32)
	speedModifier = terrain.getSpeedModifierAt(pos)
func _process(delta):
	var pos:Vector2i = Vector2i(position/32)
	if(odlPos != pos):
		speedModifier = terrain.getSpeedModifierAt(pos)
		odlPos = pos
	match state:
		s.IDLE:idleMovement(delta)
		s.MOVING_IDLE:
			if(caseMovement(delta)):
				state = s.IDLE
		s.MOVING:
			if(caseMovement(delta)):
				pathTo.pop_front()
				if pathTo.is_empty():
					state = stateAfterMoving
					if(state != s.IDLE):
						buildingProgress.show()
				else: nextCasePos = pathTo[0]*32+Vector2i(16,16)
		s.BUILDING_ROAD:
			buildTime-=delta
			buildingProgress.value+=delta
			if buildTime <= 0:
				state = s.IDLE
				stateAfterMoving = s.IDLE
				buildingProgress.hide()
				roadConstructedAt.emit(Vector2i(position/32))
				speedModifier = terrain.getSpeedModifierAt(pos)
		s.DELETING_ROAD:
			buildTime-=delta
			buildingProgress.value+=delta
			if buildTime <= 0:
				state = s.IDLE
				stateAfterMoving = s.IDLE
				buildingProgress.hide()
				roadDeletedAt.emit(Vector2i(position/32))
				speedModifier = terrain.getSpeedModifierAt(pos)
		s.BUILDING_BUILDING:
			buildTime-=delta
			buildingProgress.value+=delta
			if buildTime <= 0:
				state = s.IDLE
				stateAfterMoving = s.IDLE
				buildingProgress.hide()
				buildingConstructedAt.emit(Vector2i(position/32))
		s.DELETING_BUILDING:
			buildTime-=delta
			buildingProgress.value+=delta
			if buildTime <= 0:
				state = s.IDLE
				stateAfterMoving = s.IDLE
				buildingProgress.hide()
				buildingDeletedAt.emit(Vector2i(position/32))
		s.COLLECTING_WOOD:
			buildTime-=delta
			buildingProgress.value+=delta
			if buildTime <= 0:
				if workplace != null:
					stateAfterMoving = s.DEPOSING_WOOD
					state = s.MOVING
					buildingProgress.hide()
					pathTo = terrain.pathfindTo(Vector2i(position/32), Vector2i(workplace.position/32))
				else:
					stateAfterMoving = s.IDLE
					state = s.IDLE
		s.DEPOSING_WOOD:
			buildingProgress.hide()
			if workplace != null:
				workplace.addWood()
			stateAfterMoving = s.IDLE
			state = s.IDLE


func idleMovement(delta:float)->void:
	waiting-=delta
	if waiting <= 0:
		waiting = randf_range(MIN_WAITING,MAX_WAITING)
		var nextPosX = randf_range(int(self.position.x/32)*32+MIN_CASE_POS, int(self.position.x/32+1)*32-MIN_CASE_POS )
		var nextPosY = randf_range(int(self.position.y/32)*32+MIN_CASE_POS, int(self.position.y/32+1)*32-MIN_CASE_POS )
		nextCasePos = Vector2(nextPosX,nextPosY)
		state = s.MOVING_IDLE

func goBuildRoadAt(pathTo:Array[Vector2i], buildTime:float)->void:
	self.pathTo = pathTo
	self.buildTime = buildTime
	buildingProgress.max_value = buildTime
	buildingProgress.value = 0
	state = s.MOVING
	stateAfterMoving = s.BUILDING_ROAD
func goDeleteRoadAt(pathTo:Array[Vector2i], buildTime:float)->void:
	self.pathTo = pathTo
	self.buildTime = buildTime
	buildingProgress.max_value = buildTime
	buildingProgress.value = 0
	state = s.MOVING
	stateAfterMoving = s.DELETING_ROAD
func goBuildAt(pathTo:Array[Vector2i], buildTime:float)->void:
	self.pathTo = pathTo
	self.buildTime = buildTime
	buildingProgress.max_value = buildTime
	buildingProgress.value = 0
	state = s.MOVING
	stateAfterMoving = s.BUILDING_BUILDING
func goDeleteBuildingAt(pathTo:Array[Vector2i], buildTime:float)->void:
	self.pathTo = pathTo
	self.buildTime = buildTime
	buildingProgress.max_value = buildTime
	buildingProgress.value = 0
	state = s.MOVING
	stateAfterMoving = s.DELETING_BUILDING
func caseMovement(delta:float)->bool:
	if(position.distance_to(nextCasePos) < 2):
		stop()
		frame = 0
		return true
	else:
		var direction = position.direction_to(nextCasePos)
		position+=direction*SPEED*delta*speedModifier
		if(!is_playing()):
			if(direction.x <= 0 && direction.y <= 0):
				if(abs(direction.x) < abs(direction.y)): play("north")
				else: play("west")
			elif(direction.x > 0 && direction.y <= 0):
				if(abs(direction.x) < abs(direction.y)): play("north")
				else: play("east")
			elif(direction.x <= 0 && direction.y > 0):
				if(abs(direction.x) < abs(direction.y)): play("south")
				else: play("west")
			if(direction.x > 0 && direction.y > 0):
				if(abs(direction.x) < abs(direction.y)): play("south")
				else: play("east")
		return false
func goGetWoodAt(pathTo:Array[Vector2i], collectTime:float):
	self.pathTo = pathTo
	self.buildTime = collectTime
	buildingProgress.max_value = buildTime
	buildingProgress.value = 0
	state = s.MOVING
	stateAfterMoving = s.COLLECTING_WOOD
