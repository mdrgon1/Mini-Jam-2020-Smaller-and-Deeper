extends "../state.gd"

const RESPAWN_TIME = 100

var respawn_timer = 0

func enter():
	owner.gravity_multiplier = 0
	respawn_timer = 0

func update(delta):
	
	owner.movement_SM.target_vel = Vector2(0, 0)
	respawn_timer += delta
	if respawn_timer >= RESPAWN_TIME:
		return "falling"

func exit():
	owner.position = owner.respawn_position