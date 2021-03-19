extends KinematicBody2D

signal respawn

const KNOCKBACK_VECTOR = Vector2(-30, -30)
const ATTACK_COOLDOWN = .2
const STAGGER_TIME = 50
const ATTACK_OFFSET = Vector2(2.75, 2.5)
const CAMERA_DISTANCE_THRESHOLD = 70

#log that last few frames of floor contact for a Wile E. Coyote jump
var WEC_floor_log = [false, false, false, false, false, false]

onready var movement_SM = $Movement
onready var attack_scene = preload("res://Attack.tscn")
onready var enemy_attack_scene = preload("res://enemies/Enemy_Attack.tscn")
onready var sprite = $AnimatedSprite

var gravity = 7
var gravity_multiplier = 1
var up_vector = Vector2(0, -1)
var attack_timer = 0
var frozen = false
var respawn_position = Vector2(0, 0)
var respawn_vector = Vector2(0, -1)
var staggered = false
var stagger_timer: int = 10
var facing_direction: int = 0
export var health = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	movement_SM.enter()
	respawn_position = get_global_position()
	respawn_vector = up_vector

func player_attack(attack_position):
	var to_attack = (attack_position - get_global_position()).rotated(-up_vector.angle() - PI / 2)
	var knockback = Vector2(KNOCKBACK_VECTOR.x * sign(to_attack.x), KNOCKBACK_VECTOR.y * sign(to_attack.y))
	movement_SM.target_vel = knockback

func enemy_attack(attack_position):
	var to_attack = (attack_position - get_global_position()).rotated(-up_vector.angle() - PI / 2)
	var knockback = Vector2(KNOCKBACK_VECTOR.x * sign(to_attack.x), KNOCKBACK_VECTOR.y * sign(to_attack.y))
	movement_SM.target_vel = knockback
	take_damage(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if !(sprite.animation == "dying" and sprite.frame < 5):
	
		if frozen:
			delta = 0
		
		$health_bar.scale = Vector2(float(health) / 5, 1)
		
		delta *= 60
		attack_timer += delta
		stagger_timer += delta
		
		if stagger_timer >= STAGGER_TIME:
			staggered = false
		
		if staggered and stagger_timer % 8 >= 4:
			$AnimatedSprite.self_modulate = Color(3, 1, 1)
		else:
			$AnimatedSprite.self_modulate = Color(1, 1, 1)
		
		if Input.is_action_pressed("move_right"):
			facing_direction = 1
			sprite.flip_h = false
		if Input.is_action_pressed("move_left"):
			facing_direction = -1
			sprite.flip_h = true
		
		rotation = up_vector.angle() + PI / 2
		
		#update WEC floor log
		WEC_floor_log.pop_front()
		WEC_floor_log.push_back(is_on_floor())
		
		movement_SM.update(delta)
		movement_SM.target_vel = move_and_slide(movement_SM.target_vel.rotated(rotation) * delta, up_vector).rotated(-rotation)
		
		if !staggered:
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider in get_tree().get_nodes_in_group("Enemy"):
					touched_enemy(collision.collider)
		
		if Input.is_action_just_pressed("rotate_right"):
			up_vector = up_vector.rotated(PI / 2)
		if Input.is_action_just_pressed("rotate_left"):
			up_vector = up_vector.rotated(-PI / 2)
			
		if Input.is_action_just_pressed("attack") and attack_timer > ATTACK_COOLDOWN:
			$attack.play()
			attack_timer = 0
			sprite.play("attack")
			if !get_node_or_null("../Attack"):
				var attack = attack_scene.instance()
				var attack_position = get_global_position()
				attack_position += Vector2(ATTACK_OFFSET.x * facing_direction, ATTACK_OFFSET.y).rotated(up_vector.angle() + PI / 2)
				attack.set_global_position(attack_position)
				owner.add_child(attack)
				
		if Input.is_action_just_pressed("respawn"):
			death(self)
		
		if position.distance_to(get_node("../Camera2D").position) > CAMERA_DISTANCE_THRESHOLD:
			death(self)
		
		if health <= 0:
			death(self)

func _on_Level_end_transition():
	frozen = false

func _on_Level_start_transition():
	respawn_position = position
	respawn_vector = up_vector
	frozen = true

func take_damage(body):
	if body == self and !staggered:
		health -= 1
		stagger_timer = 0
		staggered = true
		$hurt.play()

func touched_enemy(enemy):
	var attack = enemy_attack_scene.instance()
	var attack_position = get_global_position().linear_interpolate(enemy.get_global_position(), 0.5)
	attack.set_global_position(attack_position)
	owner.add_child(attack)

func death(body):
	if body == self and get_global_position().distance_to(respawn_position) > 6:
		sprite.play("dying")
		$die.play()
		

func respawn():
	sprite.play("idle")
	health = 5 
	set_global_position(respawn_position)
	movement_SM.target_vel = Vector2(0, 0)
	up_vector = respawn_vector
	owner.up = -Vector2(cos(-up_vector.angle()), sin(-up_vector.angle()))
	emit_signal("respawn")

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "dying":
		respawn()
