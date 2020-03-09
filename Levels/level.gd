extends Node2D

const TRANSITION_TIME = 2
const LEVEL_GROWTH = 2

signal start_transition
signal end_transition

var transition_timer = 2
var transitioning = false
var level_index = 0
var previous_level: Node2D
var next_level: Node2D

onready var active_level = $Level1
onready var levels = ["res://Levels/intro1.tscn",
"res://Levels/intro2.tscn",
"res://Levels/Level1.tscn",
"res://Levels/Level2.tscn",
"res://Levels/Level3.tscn",
"res://Levels/Level4.tscn",
"res://Levels/Level5.tscn",
"res://Levels/Level6.tscn",
"res://Levels/Level7.tscn",
"res://Levels/Level8.tscn",
"res://Levels/Level9.tscn",
"res://Levels/Level10.tscn",
"res://Levels/Level11.tscn",
"res://Levels/Level12.tscn",
"res://Levels/Level13.tscn",
"res://Levels/credits.tscn"]
onready var player = get_tree().get_nodes_in_group("Player")[0]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _process(delta):
	transition_timer += delta
	if transition_timer > TRANSITION_TIME:
		if transitioning:
			emit_signal("end_transition")
			previous_level.queue_free()
			next_level.queue_free()
			add_child(active_level)
			transitioning = false
	else:
		previous_level.scale *= 1 + LEVEL_GROWTH * delta
		var start_pos = player.position - (active_level.get_node("Start").position).rotated(player.up_vector.angle() + PI / 2)
		var start_rot = player.up_vector.angle() + PI / 2
		var start_transform = Transform2D(Vector2(0.2, 0).rotated(start_rot), Vector2(.2, 0).rotated(start_rot), previous_level.position)
		var end_transform = Transform2D(start_rot, start_pos)
		next_level.transform = start_transform.interpolate_with(end_transform, pow(transition_timer / TRANSITION_TIME, 3))

func entered_level_end(body):
	if body == player:
		emit_signal("start_transition")
		transitioning = true
		transition_timer = 0
		previous_level = active_level.get_node("TileMaps").duplicate()
		previous_level.transform = active_level.transform
		call_deferred("add_child", previous_level)
		active_level.call_deferred("remove_child", previous_level)
		active_level.queue_free()
		
		level_index += 1
		
		var level_scene = load(levels[level_index])
		active_level = level_scene.instance()
		active_level.position = player.position - (active_level.get_node("Start").position).rotated(player.up_vector.angle() + PI / 2)
		active_level.rotation = player.up_vector.angle() + PI / 2
		
		next_level = active_level.get_node("TileMaps").duplicate()
		call_deferred("add_child", next_level)
		next_level.scale = Vector2(0, 0)
		next_level.position = previous_level.position
		next_level.z_index = -2
		for tilemap in next_level.get_children():
			tilemap.set_collision_layer(false)
			tilemap.set_collision_mask(false)
			$transition_sound.play()
		


func _on_Player_respawn():
	var level_offset = active_level.transform
	active_level.queue_free()
	active_level = load(levels[level_index]).instance()
	active_level.transform = level_offset
	call_deferred("add_child", active_level)
