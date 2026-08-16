extends Node2D

@onready var skeleton = $Skeleton
@onready var enemy = $Enemy
@onready var bones_label = $BonesLabel
@onready var create_skeleton_button = $CreateSkeletonButton

var corpse_scene = preload("res://corpse.tscn")

# Movimento
var skeleton_speed := 150.0
var enemy_speed := 100.0

# Vida
var skeleton_max_hp := 100
var enemy_hp := 100

# Dano
var skeleton_damage := 10
var enemy_damage := 8

# Combate
var attack_distance := 80.0
var attack_cooldown := 0.7
var enemy_attack_timer := 0.0

# Economia
var bones := 0
var bones_per_corpse := 5
var skeleton_cost := 5

# Skeletons
var skeletons: Array = []
var skeleton_hps: Dictionary = {}
var skeleton_attack_timers: Dictionary = {}

var skeleton_spawn_position := Vector2.ZERO


func _ready():
	skeleton_spawn_position = skeleton.position

	register_skeleton(skeleton)

	create_skeleton_button.pressed.connect(create_skeleton)

	update_bones_ui()


func _process(delta):
	if not is_instance_valid(enemy):
		return

	if skeletons.is_empty():
		return

	enemy_attack_timer = max(enemy_attack_timer - delta, 0.0)

	var target = get_closest_skeleton_to_enemy()

	if target == null:
		return

	# Movimento e ataque do Enemy
	var enemy_distance = abs(enemy.position.x - target.position.x)

	if enemy_distance > attack_distance:
		enemy.position.x -= enemy_speed * delta
	else:
		if enemy_attack_timer <= 0:
			damage_skeleton(target)
			enemy_attack_timer = attack_cooldown

	# Movimento e ataque de TODOS os Skeletons
	for current_skeleton in skeletons.duplicate():

		if not is_instance_valid(current_skeleton):
			continue

		var timer = float(
			skeleton_attack_timers.get(current_skeleton, 0.0)
		)

		timer = max(timer - delta, 0.0)

		skeleton_attack_timers[current_skeleton] = timer

		var distance = abs(
			enemy.position.x - current_skeleton.position.x
		)

		if distance > attack_distance:
			current_skeleton.position.x += skeleton_speed * delta

		else:
			if timer <= 0:
				attack_enemy(current_skeleton)

				if enemy_hp <= 0:
					kill_enemy()
					return


func register_skeleton(new_skeleton):
	skeletons.append(new_skeleton)

	skeleton_hps[new_skeleton] = skeleton_max_hp

	skeleton_attack_timers[new_skeleton] = 0.0

	print("SKELETON REGISTRADO!")
	print("TOTAL DE SKELETONS: ", skeletons.size())


func attack_enemy(attacking_skeleton):
	if not is_instance_valid(enemy):
		return

	enemy_hp -= skeleton_damage

	skeleton_attack_timers[attacking_skeleton] = attack_cooldown

	print(
		"SKELETON ATACOU! | Enemy HP: ",
		enemy_hp,
		" | Skeletons vivos: ",
		skeletons.size()
	)


func damage_skeleton(target):
	if not skeleton_hps.has(target):
		return

	skeleton_hps[target] -= enemy_damage

	print(
		"ENEMY ATACOU! | Skeleton HP: ",
		skeleton_hps[target]
	)

	if skeleton_hps[target] <= 0:
		kill_skeleton(target)


func kill_skeleton(target):
	print("SKELETON MORREU!")

	skeleton_hps.erase(target)
	skeleton_attack_timers.erase(target)
	skeletons.erase(target)

	target.queue_free()

	print("SKELETONS RESTANTES: ", skeletons.size())

	if skeletons.is_empty():
		print("TODOS OS SKELETONS MORRERAM!")
		set_process(false)


func get_closest_skeleton_to_enemy():
	var closest_skeleton = null
	var closest_distance := 1000000000.0

	for current_skeleton in skeletons:

		if not is_instance_valid(current_skeleton):
			continue

		var distance = abs(
			enemy.position.x - current_skeleton.position.x
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_skeleton = current_skeleton

	return closest_skeleton


func kill_enemy():
	print("INIMIGO MORREU!")

	var death_position = enemy.position

	spawn_corpse(death_position)

	enemy.queue_free()

	set_process(false)


func spawn_corpse(spawn_position: Vector2):
	var corpse = corpse_scene.instantiate()

	corpse.position = spawn_position

	add_child(corpse)

	corpse.pressed.connect(
		func():
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


func create_skeleton():
	if bones < skeleton_cost:
		print("BONES INSUFICIENTES!")
		return

	bones -= skeleton_cost

	var new_skeleton = skeleton.duplicate()

	var vertical_offset = 90.0 * skeletons.size()

	new_skeleton.position = skeleton_spawn_position + Vector2(
		0,
		vertical_offset
	)

	add_child(new_skeleton)

	register_skeleton(new_skeleton)

	update_bones_ui()

	print("NOVO SKELETON CRIADO!")
	print("TOTAL DE BONES: ", bones)


func update_bones_ui():
	bones_label.text = "Bones: " + str(bones)

	create_skeleton_button.disabled = bones < skeleton_cost
