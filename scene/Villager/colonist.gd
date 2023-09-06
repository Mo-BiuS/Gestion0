extends AnimatedSprite2D

enum s { IDLE , MOVING_ON_CASE }
var state = s.IDLE

const MIN_WAITING:float = 0.5
const MAX_WAITING:float = 1.5
var waiting:float = randf_range(MIN_WAITING,MAX_WAITING)

const MIN_CASE_POS = 2
const SPEED = 5.0
var nextCasePos:Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		match state:
			s.IDLE:idleMovement(delta)
			s.MOVING_ON_CASE:caseMovement(delta)

func idleMovement(delta:float)->void:
	waiting-=delta
	if waiting <= 0:
		waiting = randf_range(MIN_WAITING,MAX_WAITING)
		var nextPosX = randf_range(int(self.position.x/32)*32+MIN_CASE_POS, int(self.position.x/32+1)*32-MIN_CASE_POS )
		var nextPosY = randf_range(int(self.position.y/32)*32+MIN_CASE_POS, int(self.position.y/32+1)*32-MIN_CASE_POS )
		nextCasePos = Vector2(nextPosX,nextPosY)
		state = s.MOVING_ON_CASE
func caseMovement(delta:float)->void:
	if(position.distance_to(nextCasePos) < SPEED*2):
		state = s.IDLE
		stop()
		frame = 0
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
