extends Node2D

const KNOCKBACK = 30

var lifetime = .2

func _process(delta):
	$AnimatedSprite.play("default")
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
	
	for body in $Area2D.get_overlapping_bodies():
		if body in get_tree().get_nodes_in_group("Player") or body in get_tree().get_nodes_in_group("Enemy"):
			body.player_attack(get_global_position())