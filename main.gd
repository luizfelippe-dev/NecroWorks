extends Node2D

@onready var skeleton = $Skeleton
@onready var enemy = $Enemy

var skeleton_speed := 150.0
var enemy_speed := 100.0

var skeleton_hp := 100
var enemy_hp := 100

var skeleton_damage := 10
var enemy_damage := 8

var attack_distance := 80.0
var attack_cooldown := 0.7
var attack_timer := 0.0


func _process(delta):
	attack_timer -= delta

	var distance = abs(enemy.position.x - skeleton.position.x)

	if distance > attack_distance:
		skeleton.position.x += skeleton_speed * delta
		enemy.position.x -= enemy_speed * delta
	else:
		if attack_timer <= 0:
			attack()
			attack_timer = attack_cooldown


func attack():
	enemy_hp -= skeleton_damage
	skeleton_hp -= enemy_damage

	print("Esqueleto HP: ", skeleton_hp, " | Inimigo HP: ", enemy_hp)

	if enemy_hp <= 0:
		print("INIMIGO MORREU!")
		enemy.queue_free()
		set_process(false)

	elif skeleton_hp <= 0:
		print("ESQUELETO MORREU!")
		skeleton.queue_free()
		set_process(false)
