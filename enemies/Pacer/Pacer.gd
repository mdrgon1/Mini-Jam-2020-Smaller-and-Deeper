tool
extends KinematicBody2D

const GRAVITY_MAGNITUDE = 100
const KNOCKBACK_VECTOR = Vector2 (-20, -15)
const STAGGER_TIME = .4

export var shooter: bool = true
export var gravity_vector: Vector2 = Vector2(0, 1)
export var speed: float = 6
export var distance: int = 6
export var facing: Vector2 = Vector2(1, 0)
export var cooldown: float = 1
export var sight_range: float = 100
export var health = 3
export var flipped = false

var pace_timer = 0
var shoot_timer = 0
var stagger_timer = 5
var vel = Vector2(0, 0)
var projectile_scene
var shooting = false
var staggered = false
var dead = false
var period

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	if speed != 0:
		period = distance * 6 / speed
	else:
		period = INF
	
	$Sprite.flip_h = !flipped
	gravity_vector = gravity_vector.rotated(owner.rotation)
	facing = facing.rotated(owner.rotation)
	if shooter:
		projectile_scene = preload("res://enemies/projectile.tscn")

func _physics_process(delta):
	
	if !dead:
		if !Engine.editor_hint:
			pace_timer += delta
			shoot_timer += delta
			stagger_timer += delta
			
			if health <= 0:
				death()
			
			if pace_timer > period:
				facing = facing.rotated(PI)
				$Sprite.flip_h = !$Sprite.flip_h
				pace_timer = 0
			
			if shoot_timer > cooldown and shooting and !staggered:
				shoot()
				shoot_timer = 0
				
			if stagger_timer >= STAGGER_TIME:
				$Sprite.self_modulate = Color(1, 1, 1)
				staggered = false
				
			if int(stagger_timer * 60) % 2 == 1 and staggered:
				$Sprite.self_modulate = Color(3, 1, 1)
			else:
				if shooting:
					$Sprite.self_modulate = Color(1, 0, 0)
				else:
					$Sprite.self_modulate = Color(1, 1, 1)
			
			shooting = check_sightline()
				
			if !staggered:
				vel = vel.project(gravity_vector) + facing * speed
			vel += gravity_vector * GRAVITY_MAGNITUDE * delta
			
			vel = move_and_slide(vel, gravity_vector.rotated(PI))
		else:
			$Sprite.flip_h = !flipped
	elif !$damage.playing:
		queue_free()
	
func shoot():
	var projectile = projectile_scene.instance()
	projectile.direction = facing.rotated(-owner.rotation)
	projectile.position = position
	owner.add_child(projectile)
	$shoot.play()
	
func check_sightline():
	var to_player = player.get_global_transform().get_origin() - get_global_transform().get_origin()
	if (to_player - to_player.project(facing)).length() < 5 and to_player.dot(facing) > 0 and to_player.length() < sight_range:
		return true
	else:
		return false

func player_attack(attack_position):
	if !staggered:
		$damage.play()
		health -= 1
		staggered = true
		stagger_timer = 0
	var to_attack = attack_position - get_global_position()
	var knockback = Vector2(KNOCKBACK_VECTOR.x * sign(to_attack.x), KNOCKBACK_VECTOR.y * sign(to_attack.y))
	vel = knockback

func death():
	$damage.play()
	dead = true
	$CollisionShape2D.queue_free()
	$Sprite.queue_free()