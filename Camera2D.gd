extends Camera2D

const DISTANCE_THRESHOLD = 3
const POSITION_SLERP = 10
const HEIGHT_OFFSET = 3
const FACING_OFFSET = 18
const ORIENTATION_THRESHOLD = .05
const ROTATION_SLERP = 5

var up = Vector2(1, 0)
var player_pos: Vector2
var vector_to_player: Vector2
var distance_to_player: int
var facing = Vector2(0, 0)

var orientation: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_pos = get_node("../Player").position + (up * HEIGHT_OFFSET + facing * FACING_OFFSET).rotated(rotation)
	vector_to_player = player_pos - position
	distance_to_player = vector_to_player.length()
	
	if distance_to_player > DISTANCE_THRESHOLD:
		if Input.is_action_pressed("move_right"):
			facing.x = 1
		if Input.is_action_pressed("move_left"):
			facing.x = -1
		position += (vector_to_player * POSITION_SLERP * delta)
		
	orientation = Vector2(cos(rotation + PI/2), -sin(rotation + PI/2))
	
	up = owner.up
	
	if abs(up.angle_to(orientation)) > ORIENTATION_THRESHOLD:
		rotation += up.angle_to(orientation) * ROTATION_SLERP * delta
	else:
		rotation = -up.angle() - PI / 2
	
	set_global_position(get_global_position().round())