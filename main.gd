extends Node2D

@onready var skeleton = $Skeleton
@onready var enemy = $Enemy
@onready var bones_label = $BonesLabel
@onready var create_skeleton_button = $CreateSkeletonButton

var corpse_scene = preload("res://corpse.tscn")

var skeleton_speed := 150.0
var enemy_speed := 100.0

var skeleton_hp := 100
var enemy_hp := 100

var skeleton_damage := 10
var enemy_damage := 8

var attack_distance := 80.0
var attack_cooldown := 0.7
var attack_timer := 0.0

var bones := 0
var bones_per_corpse := 5

var skeleton_cost := 5


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

		var death_position = enemy.position

		spawn_corpse(death_position)

		enemy.queue_free()

		set_process(false)

	elif skeleton_hp <= 0:
		print("ESQUELETO MORREU!")

		skeleton.queue_free()

		set_process(false)


func spawn_corpse(spawn_position: Vector2):
	var corpse = corpse_scene.instantiate()

	corpse.position = spawn_position

	add_child(corpse)

	corpse.pressed.connect(func():
		process_corpse(corpse)
	)

	print("CADÁVER CRIADO!")


func process_corpse(corpse):
	bones += bones_per_corpse

	update_bones_ui()

	print("CADÁVER PROCESSADO!")
	print("+", bones_per_corpse, " BONES")
	print("TOTAL DE BONES: ", bones)

	corpse.queue_free()
	
func update_bones_ui():
	bones_label.text = "🦴 Bones: " + str(bones)
	create_skeleton_button.disabled = bones < skeleton_cost


func _ready():
	create_skeleton_button.pressed.connect(create_skeleton)
	update_bones_ui()
	
func create_skeleton():
	if bones < skeleton_cost:
		print("BONES INSUFICIENTES!")
		return


	bones -= skeleton_cost
	update_bones_ui()


	var new_skeleton = skeleton.duplicate()


	new_skeleton.position = Vector2(
		skeleton.position.x,
		skeleton.position.y + 90
	)


	add_child(new_skeleton)


	print("NOVO SKELETON CRIADO!")
	print("TOTAL DE BONES: ", bones)
