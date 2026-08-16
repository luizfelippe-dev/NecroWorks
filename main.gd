extends Node2D


# =========================================================
# NÓS DA CENA
# =========================================================

@onready var initial_skeleton: Node2D = $Skeleton
@onready var initial_enemy: Node2D = $Enemy

@onready var bones_label: Label = $BonesLabel
@onready var create_skeleton_button: Button = $CreateSkeletonButton


# =========================================================
# CENAS REUTILIZÁVEIS
# =========================================================

var corpse_scene: PackedScene = preload("res://corpse.tscn")
var skeleton_scene: PackedScene = preload("res://skeleton.tscn")
var enemy_scene: PackedScene = preload("res://enemy.tscn")


# =========================================================
# MOVIMENTO
# =========================================================

var skeleton_speed: float = 150.0
var enemy_speed: float = 100.0


# =========================================================
# VIDA
# =========================================================

var skeleton_max_hp: int = 100

var enemy_max_hp: int = 100
var enemy_hp: int = 100


# =========================================================
# DANO
# =========================================================

var skeleton_damage: int = 10
var enemy_damage: int = 8


# =========================================================
# COMBATE
# =========================================================

var attack_distance: float = 90.0
var attack_cooldown: float = 0.7

var enemy_attack_timer: float = 0.0


# =========================================================
# ECONOMIA
# =========================================================

# PARA TESTE:
# pode colocar 100 aqui.
#
# DEPOIS VOLTE PARA 0.
var bones: int = 100

var bones_per_corpse: int = 5
var skeleton_cost: int = 5


# =========================================================
# ENEMY
# =========================================================

var enemy: Node2D = null

const ENEMY_SPAWN_POSITION: Vector2 = Vector2(
	1650.0,
	555.0
)

var enemy_spawn_delay: float = 1.5


# =========================================================
# SKELETONS
# =========================================================

var skeletons: Array[Node2D] = []

var skeleton_hps: Dictionary = {}
var skeleton_attack_timers: Dictionary = {}


# =========================================================
# FORMAÇÃO DOS SKELETONS
# =========================================================

const SKELETON_FORMATION_COLUMNS: int = 6
const SKELETON_FORMATION_ROWS: int = 6

const MAX_SKELETONS: int = (
	SKELETON_FORMATION_COLUMNS
	* SKELETON_FORMATION_ROWS
)


# Skeleton provisório possui 70x70.
# Deixamos espaço entre eles.
const SKELETON_SPACING: Vector2 = Vector2(
	85.0,
	85.0
)


# Formação começa aqui.
#
# 6 linhas cabem tranquilamente em 1080p.
const SKELETON_FORMATION_ORIGIN: Vector2 = Vector2(
	250.0,
	350.0
)


# Quanto a formação inteira avançou.
var army_offset_x: float = 0.0


# Evita que algum bug faça o exército
# viajar infinitamente para fora da tela.
const MAX_ARMY_OFFSET_X: float = 900.0


# Skeleton -> número do slot
var skeleton_slots: Dictionary = {}


# número do slot -> ocupado
var occupied_skeleton_slots: Dictionary = {}


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# -----------------------------------------------------
	# ENEMY INICIAL
	# -----------------------------------------------------

	enemy = initial_enemy

	# Não dependemos da posição salva no editor.
	enemy.position = ENEMY_SPAWN_POSITION

	enemy_hp = enemy_max_hp


	# -----------------------------------------------------
	# SKELETON INICIAL
	# -----------------------------------------------------

	register_skeleton(
		initial_skeleton,
		0
	)


	# -----------------------------------------------------
	# BOTÃO
	# -----------------------------------------------------

	create_skeleton_button.pressed.connect(
		create_skeleton
	)


	update_bones_ui()


# =========================================================
# LOOP PRINCIPAL
# =========================================================

func _process(delta: float) -> void:

	# Estamos esperando aparecer outro Enemy.
	if not is_instance_valid(enemy):
		return


	# Não existe exército no momento.
	if skeletons.is_empty():
		return


	# -----------------------------------------------------
	# COOLDOWN DO ENEMY
	# -----------------------------------------------------

	enemy_attack_timer = maxf(
		enemy_attack_timer - delta,
		0.0
	)


	# -----------------------------------------------------
	# COOLDOWN DOS SKELETONS
	# -----------------------------------------------------

	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var current_timer: float = float(
			skeleton_attack_timers.get(
				current_skeleton,
				0.0
			)
		)


		current_timer = maxf(
			current_timer - delta,
			0.0
		)


		skeleton_attack_timers[
			current_skeleton
		] = current_timer


	# -----------------------------------------------------
	# SKELETON MAIS À FRENTE
	# -----------------------------------------------------

	var front_skeleton: Node2D = (
		get_front_skeleton()
	)


	if front_skeleton == null:
		return


	var front_distance: float = absf(
		enemy.position.x
		- front_skeleton.position.x
	)


	# =====================================================
	# MOVIMENTO
	# =====================================================

	if front_distance > attack_distance:

		# Toda a formação avança junta.
		army_offset_x += (
			skeleton_speed
			* delta
		)


		army_offset_x = minf(
			army_offset_x,
			MAX_ARMY_OFFSET_X
		)


		update_skeleton_formation_positions()


		# Enemy anda para esquerda.
		enemy.position.x -= (
			enemy_speed
			* delta
		)


		return


	# =====================================================
	# COMBATE
	# =====================================================

	# Enemy ataca o Skeleton mais avançado.
	if enemy_attack_timer <= 0.0:

		damage_skeleton(
			front_skeleton
		)

		enemy_attack_timer = attack_cooldown


	# O ataque acima pode ter matado o último Skeleton.
	if skeletons.is_empty():
		return


	# Todos os Skeletons vivos atacam.
	for current_skeleton: Node2D in skeletons.duplicate():

		if not is_instance_valid(current_skeleton):
			continue


		var timer: float = float(
			skeleton_attack_timers.get(
				current_skeleton,
				0.0
			)
		)


		if timer <= 0.0:

			attack_enemy(
				current_skeleton
			)


			if enemy_hp <= 0:

				kill_enemy()

				return


# =========================================================
# REGISTRAR SKELETON
# =========================================================

func register_skeleton(
	new_skeleton: Node2D,
	slot: int
) -> void:

	skeletons.append(
		new_skeleton
	)


	skeleton_hps[
		new_skeleton
	] = skeleton_max_hp


	skeleton_attack_timers[
		new_skeleton
	] = 0.0


	skeleton_slots[
		new_skeleton
	] = slot


	occupied_skeleton_slots[
		slot
	] = true


	# Coloca ele imediatamente
	# no slot correto da formação.
	new_skeleton.position = (
		get_skeleton_formation_position(
			slot
		)
	)


	print(
		"SKELETON REGISTRADO!"
	)

	print(
		"SLOT: ",
		slot
	)

	print(
		"TOTAL DE SKELETONS: ",
		skeletons.size()
	)


# =========================================================
# PEGAR SLOT LIVRE
# =========================================================

func get_free_skeleton_slot() -> int:

	for slot: int in range(
		MAX_SKELETONS
	):

		if not occupied_skeleton_slots.has(
			slot
		):

			return slot


	return -1


# =========================================================
# POSIÇÃO DO SLOT
# =========================================================

func get_skeleton_formation_position(
	slot: int
) -> Vector2:

	var column: int = (
		slot
		% SKELETON_FORMATION_COLUMNS
	)


	var row: int = int(
		slot
		/ SKELETON_FORMATION_COLUMNS
	)


	var result: Vector2 = (
		SKELETON_FORMATION_ORIGIN
		+ Vector2(
			float(column)
			* SKELETON_SPACING.x,

			float(row)
			* SKELETON_SPACING.y
		)
	)


	result.x += army_offset_x


	return result


# =========================================================
# ATUALIZAR FORMAÇÃO
# =========================================================

func update_skeleton_formation_positions() -> void:

	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(
			current_skeleton
		):
			continue


		if not skeleton_slots.has(
			current_skeleton
		):
			continue


		var slot: int = int(
			skeleton_slots[
				current_skeleton
			]
		)


		current_skeleton.position = (
			get_skeleton_formation_position(
				slot
			)
		)


# =========================================================
# PEGAR SKELETON DA FRENTE
# =========================================================

func get_front_skeleton() -> Node2D:

	var front_skeleton: Node2D = null

	var greatest_x: float = -1000000.0


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(
			current_skeleton
		):
			continue


		if current_skeleton.position.x > greatest_x:

			greatest_x = (
				current_skeleton.position.x
			)


			front_skeleton = (
				current_skeleton
			)


	return front_skeleton


# =========================================================
# SKELETON ATACA ENEMY
# =========================================================

func attack_enemy(
	attacking_skeleton: Node2D
) -> void:

	if not is_instance_valid(enemy):
		return


	enemy_hp -= skeleton_damage


	skeleton_attack_timers[
		attacking_skeleton
	] = attack_cooldown


	print(
		"SKELETON ATACOU! | Enemy HP: ",
		enemy_hp,
		" | Skeletons vivos: ",
		skeletons.size()
	)


# =========================================================
# ENEMY ATACA SKELETON
# =========================================================

func damage_skeleton(
	target: Node2D
) -> void:

	if not skeleton_hps.has(target):
		return


	var current_hp: int = int(
		skeleton_hps[
			target
		]
	)


	current_hp -= enemy_damage


	skeleton_hps[
		target
	] = current_hp


	print(
		"ENEMY ATACOU! | Skeleton HP: ",
		current_hp
	)


	if current_hp <= 0:

		kill_skeleton(
			target
		)


# =========================================================
# MATAR SKELETON
# =========================================================

func kill_skeleton(
	target: Node2D
) -> void:

	print(
		"SKELETON MORREU!"
	)


	# -----------------------------------------------------
	# LIBERA SLOT
	# -----------------------------------------------------

	if skeleton_slots.has(target):

		var freed_slot: int = int(
			skeleton_slots[
				target
			]
		)


		occupied_skeleton_slots.erase(
			freed_slot
		)


		skeleton_slots.erase(
			target
		)


		print(
			"SLOT LIBERADO: ",
			freed_slot
		)


	# -----------------------------------------------------
	# REMOVE DADOS
	# -----------------------------------------------------

	skeleton_hps.erase(
		target
	)


	skeleton_attack_timers.erase(
		target
	)


	skeletons.erase(
		target
	)


	# -----------------------------------------------------
	# REMOVE NÓ
	# -----------------------------------------------------

	target.queue_free()


	print(
		"SKELETONS RESTANTES: ",
		skeletons.size()
	)


	if skeletons.is_empty():

		print(
			"TODOS OS SKELETONS MORRERAM!"
		)

		print(
			"AGUARDANDO NOVO SKELETON..."
		)


	update_bones_ui()


# =========================================================
# MATAR ENEMY
# =========================================================

func kill_enemy() -> void:

	if not is_instance_valid(enemy):
		return


	print(
		"INIMIGO MORREU!"
	)


	var dead_enemy: Node2D = enemy


	var death_position: Vector2 = (
		dead_enemy.position
	)


	# Impede processar o mesmo Enemy novamente.
	enemy = null


	# Cria cadáver.
	spawn_corpse(
		death_position
	)


	# Remove inimigo.
	dead_enemy.queue_free()


	print(
		"NOVO INIMIGO EM ",
		enemy_spawn_delay,
		" SEGUNDOS..."
	)


	await get_tree().create_timer(
		enemy_spawn_delay
	).timeout


	spawn_enemy()


# =========================================================
# SPAWN DO ENEMY
# =========================================================

func spawn_enemy() -> void:

	var new_enemy_node: Node = (
		enemy_scene.instantiate()
	)


	var new_enemy: Node2D = (
		new_enemy_node as Node2D
	)


	if new_enemy == null:

		push_error(
			"enemy.tscn precisa possuir Node2D como raiz."
		)

		return


	add_child(
		new_enemy
	)


	new_enemy.position = (
		ENEMY_SPAWN_POSITION
	)


	enemy = new_enemy


	enemy_hp = enemy_max_hp


	enemy_attack_timer = 0.0


	print(
		"NOVO INIMIGO CRIADO!"
	)


	print(
		"Enemy HP: ",
		enemy_hp
	)


# =========================================================
# SPAWN DO CORPSE
# =========================================================

func spawn_corpse(
	spawn_position: Vector2
) -> void:

	var corpse_node: Node = (
		corpse_scene.instantiate()
	)


	var corpse: Button = (
		corpse_node as Button
	)


	if corpse == null:

		push_error(
			"corpse.tscn precisa possuir Button como raiz."
		)

		corpse_node.queue_free()

		return


	add_child(
		corpse
	)


	corpse.position = (
		spawn_position
	)


	corpse.pressed.connect(

		func() -> void:

			process_corpse(
				corpse
			)
	)


	print(
		"CADÁVER CRIADO!"
	)


# =========================================================
# PROCESSAR CORPSE
# =========================================================

func process_corpse(
	corpse: Button
) -> void:

	if not is_instance_valid(
		corpse
	):
		return


	bones += bones_per_corpse


	update_bones_ui()


	print(
		"CADÁVER PROCESSADO!"
	)


	print(
		"+",
		bones_per_corpse,
		" BONES"
	)


	print(
		"TOTAL DE BONES: ",
		bones
	)


	corpse.queue_free()


# =========================================================
# CRIAR SKELETON
# =========================================================

func create_skeleton() -> void:

	# -----------------------------------------------------
	# SEM BONES
	# -----------------------------------------------------

	if bones < skeleton_cost:

		print(
			"BONES INSUFICIENTES!"
		)

		return


	# -----------------------------------------------------
	# PROCURA SLOT
	# -----------------------------------------------------

	var free_slot: int = (
		get_free_skeleton_slot()
	)


	if free_slot == -1:

		print(
			"FORMAÇÃO DE SKELETONS CHEIA!"
		)

		return


	# -----------------------------------------------------
	# INSTANCIA
	# -----------------------------------------------------

	var skeleton_node: Node = (
		skeleton_scene.instantiate()
	)


	var new_skeleton: Node2D = (
		skeleton_node as Node2D
	)


	if new_skeleton == null:

		push_error(
			"skeleton.tscn precisa possuir Node2D como raiz."
		)

		skeleton_node.queue_free()

		return


	# -----------------------------------------------------
	# PAGA O CUSTO
	# -----------------------------------------------------

	bones -= skeleton_cost


	# -----------------------------------------------------
	# ADICIONA AO JOGO
	# -----------------------------------------------------

	add_child(
		new_skeleton
	)


	register_skeleton(
		new_skeleton,
		free_slot
	)


	update_bones_ui()


	print(
		"NOVO SKELETON CRIADO!"
	)


	print(
		"SLOT: ",
		free_slot
	)


	print(
		"TOTAL DE BONES: ",
		bones
	)


# =========================================================
# INTERFACE
# =========================================================

func update_bones_ui() -> void:

	bones_label.text = (
		"Bones: "
		+ str(bones)
	)


	var formation_full: bool = (
		skeletons.size()
		>= MAX_SKELETONS
	)


	create_skeleton_button.disabled = (
		bones < skeleton_cost
		or formation_full
	)
