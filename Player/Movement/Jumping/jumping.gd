extends "../state.gd"

const JUMP_POWER = 80
const FALL_THRESHOLD = 20
const MOVEMENT_SPEED = 50
const FRICTION = .07

func enter():
	owner.gravity_multiplier = .4
	owner.movement_SM.target_vel.y -= JUMP_POWER
	owner.sprite.play("jumping")
	owner.get_node("jump").play()

func update(delta):
	if owner.is_on_floor():
		if Input.is_action_pressed("jump"):
			return "jumping"
		else:
			return "running"
	
	if !Input.is_action_pressed("jump"):
		return "falling"
	
	if owner.movement_SM.target_vel.y > FALL_THRESHOLD:
		return "falling"
	
	#horizontal movement
	var direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	owner.movement_SM.target_vel.x += (direction * MOVEMENT_SPEED - owner.movement_SM.target_vel.x) * FRICTION * delta