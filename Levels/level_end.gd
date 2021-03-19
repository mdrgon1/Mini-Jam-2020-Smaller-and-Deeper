extends Area2D
var level_manager

func _ready():
	level_manager = get_tree().get_nodes_in_group("level manager")[0]
	
	connect("body_entered", level_manager, "entered_level_end")
