class_name Colonist extends AnimatedSprite2D

enum s { IDLE , MOVING_IDLE, MOVING, BUILDING }
var state = s.IDLE
var stateAfterMoving = s.IDLE

const MIN_WAITING:float = 0.5
const MAX_WAITING:float = 1.5
var waiting:float = randf_range(MIN_WAITING,MAX_WAITING)

const MIN_CASE_POS = 2
const SPEED = 8.0
var nextCasePos:Vector2
var pathTo:Array[Vector2i] = []
var buildTime:float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		s.IDLE:idleMovement(delta)
		s.MOVING_IDLE:caseMovement(delta)
		s.MOVING:
			if(caseMovement(delta)):
				pathTo.pop_front()
				if pathTo.is_empty():state = stateAfterMoving
				else: nextCasePos = pathTo[0]*32+Vector2i(16,16)
		s.BUILDING:
			buildTime-=delta
			if buildTime <= 0:
				state = s.IDLE

func idleMovement(delta:float)->void:
	waiting-=delta
	if waiting <= 0:
		waiting = randf_range(MIN_WAITING,MAX_WAITING)
		var nextPosX = randf_range(int(self.position.x/32)*32+MIN_CASE_POS, int(self.position.x/32+1)*32-MIN_CASE_POS )
		var nextPosY = randf_range(int(self.position.y/32)*32+MIN_CASE_POS, int(self.position.y/32+1)*32-MIN_CASE_POS )
		nextCasePos = Vector2(nextPosX,nextPosY)
		state = s.MOVING_IDLE

func goBuildAt(pathTo:Array[Vector2i], buildTime:float)->void:
	self.pathTo = pathTo
	self.buildTime = buildTime
	state = s.MOVING
	stateAfterMoving = s.BUILDING

func caseMovement(delta:float)->bool:
	if(position.distance_to(nextCasePos) < 2):
		state = s.IDLE
		stop()
		frame = 0
		return true
	else:
		var direction = position.direction_to(nextCasePos)
		position+=direction*SPEED*delta
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
