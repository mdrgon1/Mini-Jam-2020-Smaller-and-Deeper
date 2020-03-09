extends Node2D

var up = Vector2(0, -1)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("rotate_right"):
		up = up.rotated(-PI / 2)
	if Input.is_action_just_pressed("rotate_left"):
		up = up.rotated(PI / 2)
	
	up = up.round()