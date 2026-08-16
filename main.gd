extends Node2D


# =========================================================
# NÓS DA CENA
# =========================================================

@onready var initial_skeleton: Node2D = $Skeleton
@onready var initial_enemy: Node2D = $Enemy

@onready var bones_label: Label = $BonesLabel
@onready var create_skeleton_button: Button = $CreateSkeletonButton


# =========================================================
# CENAS
# =========================================================

var corpse_scene: PackedScene = preload("res://corpse.tscn")
var skeleton_scene: PackedScene = preload("res://skeleton.tscn")
var enemy_scene: PackedScene = preload("res://enemy.tscn")


# =========================================================
# VISUAL TEMPORÁRIO
# =========================================================

const SKELETON_COLOR: Color = Color.WHITE
const ENEMY_COLOR: Color = Color.RED

const UNIT_SIZE: float = 70.0


# =========================================================
# MOVIMENTO
# =========================================================

var skeleton_speed: float = 180.0
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

var skeleton_attack_cooldown: float = 0.7
var enemy_attack_cooldown: float = 0.7

var enemy_attack_timer: float = 0.0

# Distância em que o Enemy consegue bater.
var enemy_attack_range: float = 135.0

# Quanto o Skeleton pode estar afastado de sua posição
# de combate para considerarmos que ele chegou.
var combat_position_tolerance: float = 15.0


# =========================================================
# ECONOMIA
# =========================================================

# CHEAT TEMPORÁRIO PARA TESTE.
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

# Skeleton -> slot
var skeleton_slots: Dictionary = {}

# Slot -> ocupado
var occupied_skeleton_slots: Dictionary = {}


# =========================================================
# FORMAÇÃO DE SPAWN
# =========================================================

const FORMATION_COLUMNS: int = 6
const FORMATION_ROWS: int = 6

const MAX_SKELETONS: int = (
	FORMATION_COLUMNS
	* FORMATION_ROWS
)

const SPAWN_SPACING: Vector2 = Vector2(
	85.0,
	85.0
)

const SPAWN_ORIGIN: Vector2 = Vector2(
	250.0,
	350.0
)


# =========================================================
# FORMAÇÃO DE COMBATE
# =========================================================

# Skeletons não tentam entrar dentro do Enemy.
#
# Eles ocupam uma formação que acompanha o Enemy:
#
#       S  S
#    S  S  S     ENEMY
#       S  S
#
# Quanto maior o exército, mais colunas são formadas.

const COMBAT_ROWS: int = 6

const COMBAT_SPACING_X: float = 85.0
const COMBAT_SPACING_Y: float = 85.0

# Primeira coluna fica 110 pixels à esquerda do Enemy.
const COMBAT_FRONT_DISTANCE: float = 110.0

# Ordem das linhas:
#
# centro superior
# centro inferior
# segunda superior
# segunda inferior
# topo
# baixo
#
# Isso faz os primeiros Skeletons ficarem próximos
# do centro em vez de começar pelo topo.
const COMBAT_ROW_ORDER: Array[int] = [
	2,
	3,
	1,
	4,
	0,
	5
]


# =========================================================
# DEBUG
# =========================================================

var debug_label: Label = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	create_debug_hud()


	# -----------------------------------------------------
	# ENEMY INICIAL
	# -----------------------------------------------------

	enemy = initial_enemy

	enemy.position = ENEMY_SPAWN_POSITION

	enemy_hp = enemy_max_hp

	ensure_unit_visual(
		enemy,
		ENEMY_COLOR
	)


	# -----------------------------------------------------
	# SKELETON INICIAL
	# -----------------------------------------------------

	ensure_unit_visual(
		initial_skeleton,
		SKELETON_COLOR
	)

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
	update_debug_ui()


# =========================================================
# LOOP PRINCIPAL
# =========================================================

func _process(delta: float) -> void:

	update_debug_ui()


	# Estamos entre um Enemy e outro.
	if not is_instance_valid(enemy):
		return


	# Não existe exército.
	# O Enemy fica esperando.
	if skeletons.is_empty():
		return


	# =====================================================
	# COOLDOWNS
	# =====================================================

	enemy_attack_timer = maxf(
		enemy_attack_timer - delta,
		0.0
	)


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var timer: float = float(
			skeleton_attack_timers.get(
				current_skeleton,
				0.0
			)
		)


		timer = maxf(
			timer - delta,
			0.0
		)


		skeleton_attack_timers[
			current_skeleton
		] = timer


	# =====================================================
	# ENEMY PERSEGUE O SKELETON MAIS PRÓXIMO
	# =====================================================

	var closest_skeleton: Node2D = (
		get_closest_skeleton_to_enemy()
	)


	if closest_skeleton == null:
		return


	var distance_to_skeleton: float = (
		enemy.position.distance_to(
			closest_skeleton.position
		)
	)


	if distance_to_skeleton > enemy_attack_range:

		enemy.position = (
			enemy.position.move_toward(
				closest_skeleton.position,
				enemy_speed * delta
			)
		)

	else:

		if enemy_attack_timer <= 0.0:

			damage_skeleton(
				closest_skeleton
			)

			enemy_attack_timer = (
				enemy_attack_cooldown
			)


	# O Enemy pode ter acabado de matar
	# o último Skeleton.
	if skeletons.is_empty():
		return


	# =====================================================
	# CADA SKELETON PROCURA SUA POSIÇÃO DE COMBATE
	# =====================================================

	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
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


		var combat_target: Vector2 = (
			get_combat_target_position(
				slot
			)
		)


		var distance_to_target: float = (
			current_skeleton.position.distance_to(
				combat_target
			)
		)


		# -------------------------------------------------
		# AINDA NÃO CHEGOU NO INIMIGO
		# -------------------------------------------------

		if distance_to_target > combat_position_tolerance:

			current_skeleton.position = (
				current_skeleton.position.move_toward(
					combat_target,
					skeleton_speed * delta
				)
			)


		# -------------------------------------------------
		# CHEGOU NA POSIÇÃO DE COMBATE
		# -------------------------------------------------

		else:

			var attack_timer: float = float(
				skeleton_attack_timers.get(
					current_skeleton,
					0.0
				)
			)


			if attack_timer <= 0.0:

				attack_enemy(
					current_skeleton
				)


				if enemy_hp <= 0:

					kill_enemy()

					return


# =========================================================
# POSIÇÃO DE COMBATE DO SKELETON
# =========================================================

func get_combat_target_position(
	slot: int
) -> Vector2:

	if not is_instance_valid(enemy):

		return get_spawn_position(
			slot
		)


	# Temos 6 Skeletons por coluna.
	var combat_column: int = int(
		slot / COMBAT_ROWS
	)


	var slot_inside_column: int = (
		slot % COMBAT_ROWS
	)


	var row_index: int = int(
		COMBAT_ROW_ORDER[
			slot_inside_column
		]
	)


	# Centraliza verticalmente as 6 linhas.
	var vertical_offset: float = (
		(
			float(row_index)
			- 2.5
		)
		* COMBAT_SPACING_Y
	)


	# Primeira coluna fica perto do Enemy.
	# As outras ficam progressivamente mais atrás.
	var horizontal_offset: float = (
		COMBAT_FRONT_DISTANCE
		+ (
			float(combat_column)
			* COMBAT_SPACING_X
		)
	)


	return Vector2(
		enemy.position.x
		- horizontal_offset,

		enemy.position.y
		+ vertical_offset
	)


# =========================================================
# POSIÇÃO DE SPAWN
# =========================================================

func get_spawn_position(
	slot: int
) -> Vector2:

	var column: int = (
		slot
		% FORMATION_COLUMNS
	)


	var row: int = int(
		slot
		/ FORMATION_COLUMNS
	)


	return (
		SPAWN_ORIGIN
		+ Vector2(
			float(column)
			* SPAWN_SPACING.x,

			float(row)
			* SPAWN_SPACING.y
		)
	)


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


	# IMPORTANTE:
	# Todo Skeleton novo nasce NA BASE.
	#
	# Não nasce mais na posição do exército
	# ou perto do Enemy.
	new_skeleton.position = (
		get_spawn_position(
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
# SKELETON MAIS PRÓXIMO DO ENEMY
# =========================================================

func get_closest_skeleton_to_enemy() -> Node2D:

	if not is_instance_valid(enemy):
		return null


	var closest_skeleton: Node2D = null

	var closest_distance: float = INF


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var distance: float = (
			enemy.position.distance_to(
				current_skeleton.position
			)
		)


		if distance < closest_distance:

			closest_distance = distance

			closest_skeleton = (
				current_skeleton
			)


	return closest_skeleton


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
	] = skeleton_attack_cooldown


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
	# REMOVE DOS SISTEMAS
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
			"AGUARDANDO REFORÇOS..."
		)


	update_bones_ui()
	update_debug_ui()


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


	enemy = null


	spawn_corpse(
		death_position
	)


	dead_enemy.queue_free()


	update_debug_ui()


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
# SPAWN ENEMY
# =========================================================

func spawn_enemy() -> void:

	var enemy_node: Node = (
		enemy_scene.instantiate()
	)


	var new_enemy: Node2D = (
		enemy_node as Node2D
	)


	if new_enemy == null:

		push_error(
			"enemy.tscn precisa ter Node2D como raiz."
		)

		enemy_node.queue_free()

		return


	add_child(
		new_enemy
	)


	new_enemy.position = (
		ENEMY_SPAWN_POSITION
	)


	ensure_unit_visual(
		new_enemy,
		ENEMY_COLOR
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


	update_debug_ui()


# =========================================================
# SPAWN CORPSE
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
			"corpse.tscn precisa ter Button como raiz."
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

	if not is_instance_valid(corpse):
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

	if bones < skeleton_cost:

		print(
			"BONES INSUFICIENTES!"
		)

		return


	var free_slot: int = (
		get_free_skeleton_slot()
	)


	if free_slot == -1:

		print(
			"LIMITE DE SKELETONS ATINGIDO!"
		)

		return


	var skeleton_node: Node = (
		skeleton_scene.instantiate()
	)


	var new_skeleton: Node2D = (
		skeleton_node as Node2D
	)


	if new_skeleton == null:

		push_error(
			"skeleton.tscn precisa ter Node2D como raiz."
		)

		skeleton_node.queue_free()

		return


	bones -= skeleton_cost


	add_child(
		new_skeleton
	)


	ensure_unit_visual(
		new_skeleton,
		SKELETON_COLOR
	)


	register_skeleton(
		new_skeleton,
		free_slot
	)


	update_bones_ui()
	update_debug_ui()


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
# VISUAL TEMPORÁRIO
# =========================================================

func ensure_unit_visual(
	unit: Node2D,
	color: Color
) -> void:

	var existing_node: Node = (
		unit.get_node_or_null(
			"DebugVisual"
		)
	)


	if existing_node != null:

		var existing_visual: Polygon2D = (
			existing_node as Polygon2D
		)


		if existing_visual != null:

			existing_visual.color = color


		return


	var visual: Polygon2D = Polygon2D.new()

	visual.name = "DebugVisual"

	visual.color = color

	visual.z_index = 10


	var half_size: float = (
		UNIT_SIZE / 2.0
	)


	var points: PackedVector2Array = PackedVector2Array(
		[
			Vector2(
				-half_size,
				-half_size
			),

			Vector2(
				half_size,
				-half_size
			),

			Vector2(
				half_size,
				half_size
			),

			Vector2(
				-half_size,
				half_size
			)
		]
	)


	visual.polygon = points


	unit.add_child(
		visual
	)


# =========================================================
# DEBUG HUD
# =========================================================

func create_debug_hud() -> void:

	debug_label = Label.new()

	debug_label.name = "DebugLabel"

	debug_label.position = Vector2(
		40.0,
		165.0
	)

	debug_label.size = Vector2(
		500.0,
		160.0
	)


	add_child(
		debug_label
	)


func update_debug_ui() -> void:

	if debug_label == null:
		return


	var enemy_text: String = "SPAWNING"


	if is_instance_valid(enemy):

		enemy_text = (
			str(enemy_hp)
			+ " HP"
		)


	var closest_distance_text: String = "-"


	if (
		is_instance_valid(enemy)
		and not skeletons.is_empty()
	):

		var closest: Node2D = (
			get_closest_skeleton_to_enemy()
		)


		if closest != null:

			var distance: float = (
				enemy.position.distance_to(
					closest.position
				)
			)


			closest_distance_text = str(
				round(distance)
			)


	debug_label.text = (
		"DEBUG"
		+ "\nSkeletons: "
		+ str(skeletons.size())
		+ "\nEnemy: "
		+ enemy_text
		+ "\nClosest distance: "
		+ closest_distance_text
	)


# =========================================================
# BONES UI
# =========================================================

func update_bones_ui() -> void:

	bones_label.text = (
		"Bones: "
		+ str(bones)
	)


	var full: bool = (
		skeletons.size()
		>= MAX_SKELETONS
	)


	create_skeleton_button.disabled = (
		bones < skeleton_cost
		or full
	)
