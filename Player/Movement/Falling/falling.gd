extends "../state.gd"

const MOVEMENT_SPEED = 60
const FRICTION = .09

func enter():
	owner.gravity_multiplier = 1
	if owner.sprite.animation != "attack":
		owner.sprite.play("falling")

func update(delta):
	
	#transition immediately out of falling if necessary
	if owner.is_on_floor():
		if Input.is_action_pressed("jump"):
			return "jumping"
		else:
			return "running"
			
	#horizontal movement
	var direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	owner.movement_SM.target_vel.x += (direction * MOVEMENT_SPEED - owner.movement_SM.target_vel.x) * FRICTION * delta