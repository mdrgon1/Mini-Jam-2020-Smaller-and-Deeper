extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_tree().get_nodes_in_group("Player")[0]
# Called when the node enters the scene tree for the first time.
func _ready():
	if !overlaps_body(player):
		connect("body_entered", player, "death")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
