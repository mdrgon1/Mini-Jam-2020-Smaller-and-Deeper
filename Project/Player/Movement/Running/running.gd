extends "../state.gd"

const MOVEMENT_SPEED = 60
const FRICTION = .11

func enter():
	owner.gravity_multiplier = 1
	
func update(delta):
	if !owner.WEC_floor_log[0]:
		return "falling"
	
	if Input.is_action_pressed("jump"):
		return "jumping"
		
	#horizonta movement
	var direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	owner.movement_SM.target_vel.x += (direction * MOVEMENT_SPEED - owner.movement_SM.target_vel.x) * FRICTION * delta
	
	if !(owner.sprite.animation == "attack" and owner.sprite.frame < 9) :
		if direction != 0:
			owner.sprite.play("running")
		else:
			owner.sprite.play("idle")	
