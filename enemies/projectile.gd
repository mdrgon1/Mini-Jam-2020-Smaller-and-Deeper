extends Area2D

const SPEED = 50

onready var enemy_attack_scene = preload("res://enemies/Enemy_Attack.tscn")

var direction: Vector2
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	rotation = direction.angle()
	connect("body_entered", self, "despawn")
	
func _physics_process(delta):
	position += direction * SPEED * delta

func despawn(body):
	if body == player:
		var attack = enemy_attack_scene.instance()
		attack.position = position
		get_node("..").call_deferred("add_child", attack)
		queue_free()