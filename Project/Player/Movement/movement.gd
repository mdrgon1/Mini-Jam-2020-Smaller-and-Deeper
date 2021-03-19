extends "state.gd"
#top level of the movement state machine, handles movement/gravity
#target velocity that is passed up to the player
var target_vel = Vector2(0, 0)

func update(delta):	
	
	if owner.sprite.animation != "dying":
		update_state(current_state.update(delta))
		target_vel.y += owner.gravity * owner.gravity_multiplier * delta
		
	return target_vel
	
	if Input.is_action_just_pressed("rotate_right"):
		target_vel = target_vel.rotated(-PI / 2)
	if Input.is_action_just_pressed("rotate_left"):
		target_vel = target_vel.rotated(PI / 2)
	
onready var substates_map = {
	"running"	:	$Running,
	"jumping"	:	$Jumping,
	"falling"	:	$Falling,
	"dying"		:	$Dying
}
onready var current_state = substates_map["falling"]

func get_state_name(state):
	for key in substates_map:
		if state == substates_map[key]:
			return key


func update_state(state_name):
	
#	print("targ_vel: ", target_vel)
#	print("curr_state: ", get_state_name(current_state))
#	print("up: ", owner.up_vector)
#	print("rotation: ", owner.rotation)
#	print("\n")
	
	if state_name:
		if substates_map[state_name] != current_state:
			current_state.exit()
			current_state = substates_map[state_name]
			current_state.enter()
