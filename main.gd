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
const ELITE_ENEMY_COLOR: Color = Color(0.55, 0.05, 0.15, 1.0)

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

# Quanto o Skeleton pode estar afastado da posição
# de combate para considerarmos que ele chegou.
var combat_position_tolerance: float = 15.0


# =========================================================
# ECONOMIA
# =========================================================

# BUILD ESTÁVEL: 0
# Se quiser acelerar um teste manual, pode colocar 100
# temporariamente e voltar para 0 antes do commit.
var bones: int = 0

var bones_per_corpse: int = 8
var skeleton_cost: int = 5


# =========================================================
# ENEMY
# =========================================================

var enemy: Node2D = null

const ENEMY_SPAWN_POSITION: Vector2 = Vector2(
	1650.0,
	555.0
)

# Dentro da mesma Wave o próximo Enemy aparece rápido.
var enemy_spawn_delay: float = 0.5


# =========================================================
# WAVES
# =========================================================

var current_wave: int = 1

var enemies_total_this_wave: int = 0
var enemies_defeated_this_wave: int = 0

var wave_in_progress: bool = false
var wave_transition_in_progress: bool = false


const BASE_ENEMIES_PER_WAVE: int = 5
const ENEMIES_PER_WAVE_GROWTH: int = 1

const BASE_ENEMY_HP: int = 100
const ENEMY_HP_GROWTH: int = 20

const BASE_ENEMY_DAMAGE: int = 7
const ENEMY_DAMAGE_GROWTH: int = 1

const ELITE_WAVE_INTERVAL: int = 5
const ELITE_ENEMIES_PER_WAVE: int = 5
const ELITE_HP_MULTIPLIER: float = 1.4
const ELITE_DAMAGE_BONUS: int = 3


# =========================================================
# UPGRADES
# =========================================================

const UPGRADE_SHARPENED_BONES: String = "sharpened_bones"
const UPGRADE_BONE_PLATING: String = "bone_plating"
const UPGRADE_EFFICIENT_RECYCLING: String = "efficient_recycling"

var upgrade_counts: Dictionary = {}
var total_upgrades_selected: int = 0
var upgrade_panel: ColorRect = null
var upgrade_title_label: Label = null
var upgrade_buttons: Array[Button] = []


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

const COMBAT_ROWS: int = 6

const COMBAT_SPACING_X: float = 85.0
const COMBAT_SPACING_Y: float = 85.0

# Primeira coluna fica 110 pixels à esquerda do Enemy.
const COMBAT_FRONT_DISTANCE: float = 110.0

# Primeiros Skeletons ocupam as linhas centrais primeiro.
const COMBAT_ROW_ORDER: Array[int] = [
	2,
	3,
	1,
	4,
	0,
	5
]


# =========================================================
# HUD
# =========================================================

var debug_label: Label = null
var wave_label: Label = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	create_debug_hud()
	create_wave_hud()
	create_upgrade_ui()


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


	# -----------------------------------------------------
	# WAVE 1
	# -----------------------------------------------------

	start_wave(
		current_wave,
		initial_enemy
	)


	update_bones_ui()
	update_wave_ui()
	update_debug_ui()


# =========================================================
# LOOP PRINCIPAL
# =========================================================

func _process(delta: float) -> void:

	update_debug_ui()


	# Estamos entre um Enemy e outro ou entre Waves.
	if not is_instance_valid(enemy):
		return


	# Sem exército, o Enemy fica esperando.
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


	# Enemy pode ter matado o último Skeleton.
	if skeletons.is_empty():
		return


	# =====================================================
	# SKELETONS BUSCAM POSIÇÃO DE COMBATE
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


		if distance_to_target > combat_position_tolerance:

			current_skeleton.position = (
				current_skeleton.position.move_toward(
					combat_target,
					skeleton_speed * delta
				)
			)

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
# WAVES
# =========================================================

func start_wave(
	wave_number: int,
	existing_enemy: Node2D = null
) -> void:

	current_wave = wave_number

	enemies_total_this_wave = (
		get_enemies_for_wave(
			current_wave
		)
	)

	enemies_defeated_this_wave = 0

	enemy_max_hp = (
		get_enemy_hp_for_wave(
			current_wave
		)
	)

	enemy_damage = (
		get_enemy_damage_for_wave(
			current_wave
		)
	)

	wave_in_progress = true
	wave_transition_in_progress = false


	print("")
	print("==============================")
	print("WAVE ", current_wave, " INICIADA!")

	if is_elite_wave(current_wave):
		print("ELITE WAVE!")

	print(
		"Enemies: ",
		enemies_total_this_wave
	)

	print(
		"Enemy HP: ",
		enemy_max_hp,
		" | Damage: ",
		enemy_damage
	)

	print("==============================")


	if is_instance_valid(existing_enemy):

		enemy = existing_enemy

		enemy.position = (
			ENEMY_SPAWN_POSITION
		)

		enemy_hp = enemy_max_hp

		enemy_attack_timer = 0.0

		ensure_unit_visual(
			enemy,
			get_current_enemy_color()
		)

	else:

		spawn_enemy()


	update_wave_ui()
	update_debug_ui()


func get_enemies_for_wave(
	wave_number: int
) -> int:

	if is_elite_wave(wave_number):
		return ELITE_ENEMIES_PER_WAVE


	return (
		BASE_ENEMIES_PER_WAVE
		+ (
			(wave_number - 1)
			* ENEMIES_PER_WAVE_GROWTH
		)
	)


func get_enemy_hp_for_wave(
	wave_number: int
) -> int:

	var result: int = (
		BASE_ENEMY_HP
		+ (
			(wave_number - 1)
			* ENEMY_HP_GROWTH
		)
	)


	if is_elite_wave(wave_number):

		result = int(
			float(result)
			* ELITE_HP_MULTIPLIER
		)


	return result


func get_enemy_damage_for_wave(
	wave_number: int
) -> int:

	var result: int = (
		BASE_ENEMY_DAMAGE
		+ (
			(wave_number - 1)
			* ENEMY_DAMAGE_GROWTH
		)
	)


	if is_elite_wave(wave_number):

		result += ELITE_DAMAGE_BONUS


	return result


func is_elite_wave(
	wave_number: int
) -> bool:

	return (
		wave_number > 0
		and wave_number % ELITE_WAVE_INTERVAL == 0
	)


func get_current_enemy_color() -> Color:

	if is_elite_wave(current_wave):
		return ELITE_ENEMY_COLOR


	return ENEMY_COLOR


func get_enemies_remaining() -> int:

	var remaining: int = (
		enemies_total_this_wave
		- enemies_defeated_this_wave
	)


	if remaining < 0:
		remaining = 0


	return remaining


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


	var vertical_offset: float = (
		(
			float(row_index)
			- 2.5
		)
		* COMBAT_SPACING_Y
	)


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
# MATAR ENEMY / PROGREDIR WAVE
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


	enemies_defeated_this_wave += 1


	print(
		"ENEMIES DERROTADOS NA WAVE: ",
		enemies_defeated_this_wave,
		" / ",
		enemies_total_this_wave
	)


	update_wave_ui()
	update_debug_ui()


	# =====================================================
	# WAVE COMPLETA
	# =====================================================

	if (
		enemies_defeated_this_wave
		>= enemies_total_this_wave
	):

		wave_in_progress = false
		wave_transition_in_progress = true


		print("")
		print("==============================")
		print(
			"WAVE ",
			current_wave,
			" COMPLETE!"
		)
		print(
			"AGUARDANDO ESCOLHA DE UPGRADE..."
		)
		print("==============================")


		update_wave_ui()
		show_upgrade_selection()


		return


	# =====================================================
	# PRÓXIMO ENEMY DA MESMA WAVE
	# =====================================================

	print(
		"PRÓXIMO INIMIGO EM ",
		enemy_spawn_delay,
		" SEGUNDOS..."
	)


	await get_tree().create_timer(
		enemy_spawn_delay
	).timeout


	if (
		wave_in_progress
		and not is_instance_valid(enemy)
	):

		spawn_enemy()


# =========================================================
# SPAWN ENEMY
# =========================================================

func spawn_enemy() -> void:

	if not wave_in_progress:
		return


	if is_instance_valid(enemy):
		return


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
		get_current_enemy_color()
	)


	enemy = new_enemy

	enemy_hp = enemy_max_hp

	enemy_attack_timer = 0.0


	print(
		"NOVO INIMIGO CRIADO!"
	)

	print(
		"Wave: ",
		current_wave,
		" | Enemy HP: ",
		enemy_hp,
		" | Damage: ",
		enemy_damage
	)


	update_wave_ui()
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
# UPGRADE SYSTEM
# =========================================================

func create_upgrade_ui() -> void:
	upgrade_panel = ColorRect.new()
	upgrade_panel.name = "UpgradePanel"
	upgrade_panel.position = Vector2(300.0, 220.0)
	upgrade_panel.size = Vector2(1320.0, 500.0)
	upgrade_panel.color = Color(0.04, 0.04, 0.04, 0.96)
	upgrade_panel.z_index = 500
	add_child(upgrade_panel)

	upgrade_title_label = Label.new()
	upgrade_title_label.name = "UpgradeTitle"
	upgrade_title_label.position = Vector2(40.0, 25.0)
	upgrade_title_label.size = Vector2(1240.0, 50.0)
	upgrade_title_label.text = "SELECT AN UPGRADE"
	upgrade_panel.add_child(upgrade_title_label)

	create_upgrade_button(UPGRADE_SHARPENED_BONES, 0)
	create_upgrade_button(UPGRADE_BONE_PLATING, 1)
	create_upgrade_button(UPGRADE_EFFICIENT_RECYCLING, 2)

	upgrade_panel.visible = false


func create_upgrade_button(upgrade_id: String, index: int) -> void:
	var button: Button = Button.new()
	button.name = "UpgradeButton" + str(index + 1)
	button.position = Vector2(40.0 + float(index) * 420.0, 100.0)
	button.size = Vector2(390.0, 340.0)

	button.pressed.connect(
		select_upgrade.bind(upgrade_id)
	)

	upgrade_panel.add_child(button)
	upgrade_buttons.append(button)


func show_upgrade_selection() -> void:
	if upgrade_panel == null:
		return

	if not wave_transition_in_progress:
		return

	update_upgrade_ui()
	upgrade_panel.visible = true

	print("")
	print("------------------------------")
	print("SELECT AN UPGRADE")
	print("1. Sharpened Bones")
	print("2. Bone Plating")
	print("3. Efficient Recycling")
	print("------------------------------")


func hide_upgrade_selection() -> void:
	if upgrade_panel == null:
		return

	upgrade_panel.visible = false


func update_upgrade_ui() -> void:
	if upgrade_panel == null:
		return

	if upgrade_title_label != null:
		upgrade_title_label.text = (
			"WAVE "
			+ str(current_wave)
			+ " COMPLETE — SELECT AN UPGRADE"
		)

	if upgrade_buttons.size() < 3:
		return

	upgrade_buttons[0].text = (
		"SHARPENED BONES"
		+ "\n\nSkeleton Damage +25%"
		+ "\n\nCurrent DMG: "
		+ str(skeleton_damage)
		+ "\nTaken: "
		+ str(get_upgrade_count(UPGRADE_SHARPENED_BONES))
	)

	upgrade_buttons[1].text = (
		"BONE PLATING"
		+ "\n\nSkeleton Max HP +25"
		+ "\nExisting Skeletons also gain +25 HP"
		+ "\n\nCurrent Max HP: "
		+ str(skeleton_max_hp)
		+ "\nTaken: "
		+ str(get_upgrade_count(UPGRADE_BONE_PLATING))
	)

	upgrade_buttons[2].text = (
		"EFFICIENT RECYCLING"
		+ "\n\nCorpses generate +2 Bones"
		+ "\n\nCurrent Bones/Corpse: "
		+ str(bones_per_corpse)
		+ "\nTaken: "
		+ str(get_upgrade_count(UPGRADE_EFFICIENT_RECYCLING))
	)


func get_upgrade_count(upgrade_id: String) -> int:
	return int(
		upgrade_counts.get(upgrade_id, 0)
	)


func select_upgrade(upgrade_id: String) -> void:
	if not wave_transition_in_progress:
		return

	apply_upgrade(upgrade_id)

	var previous_count: int = get_upgrade_count(upgrade_id)
	upgrade_counts[upgrade_id] = previous_count + 1
	total_upgrades_selected += 1

	print("")
	print("==============================")
	print("UPGRADE SELECTED: ", get_upgrade_name(upgrade_id))
	print(
		"Skeleton DMG: ",
		skeleton_damage,
		" | Max HP: ",
		skeleton_max_hp,
		" | Bones/Corpse: ",
		bones_per_corpse
	)
	print("==============================")

	hide_upgrade_selection()
	wave_transition_in_progress = false
	current_wave += 1
	start_wave(current_wave)


func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		UPGRADE_SHARPENED_BONES:
			var new_damage: int = int(
				ceil(float(skeleton_damage) * 1.25)
			)

			if new_damage <= skeleton_damage:
				new_damage = skeleton_damage + 1

			skeleton_damage = new_damage

		UPGRADE_BONE_PLATING:
			skeleton_max_hp += 25

			for current_skeleton: Node2D in skeletons:
				if not is_instance_valid(current_skeleton):
					continue

				if not skeleton_hps.has(current_skeleton):
					continue

				var current_hp: int = int(
					skeleton_hps[current_skeleton]
				)

				skeleton_hps[current_skeleton] = current_hp + 25

		UPGRADE_EFFICIENT_RECYCLING:
			bones_per_corpse += 2

		_:
			push_error(
				"Upgrade desconhecido: " + upgrade_id
			)

	update_bones_ui()
	update_debug_ui()


func get_upgrade_name(upgrade_id: String) -> String:
	match upgrade_id:
		UPGRADE_SHARPENED_BONES:
			return "Sharpened Bones"

		UPGRADE_BONE_PLATING:
			return "Bone Plating"

		UPGRADE_EFFICIENT_RECYCLING:
			return "Efficient Recycling"

		_:
			return "Unknown Upgrade"


# =========================================================
# WAVE HUD
# =========================================================

func create_wave_hud() -> void:

	wave_label = Label.new()

	wave_label.name = "WaveLabel"

	wave_label.position = Vector2(
		800.0,
		40.0
	)

	wave_label.size = Vector2(
		500.0,
		120.0
	)

	wave_label.z_index = 100


	add_child(
		wave_label
	)


func update_wave_ui() -> void:

	if wave_label == null:
		return


	var wave_title: String = (
		"WAVE "
		+ str(current_wave)
	)


	if is_elite_wave(current_wave):

		wave_title += " - ELITE"


	if wave_transition_in_progress:

		wave_label.text = (
			wave_title
			+ " COMPLETE"
			+ "\nSELECT AN UPGRADE"
		)

		return


	wave_label.text = (
		wave_title
		+ "\nEnemies Remaining: "
		+ str(get_enemies_remaining())
		+ " / "
		+ str(enemies_total_this_wave)
		+ "\nEnemy HP: "
		+ str(enemy_max_hp)
		+ " | DMG: "
		+ str(enemy_damage)
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
		200.0
	)


	add_child(
		debug_label
	)


func update_debug_ui() -> void:

	if debug_label == null:
		return


	var enemy_text: String = "NONE"


	if is_instance_valid(enemy):

		enemy_text = (
			str(enemy_hp)
			+ " HP"
		)

	elif wave_transition_in_progress:

		enemy_text = "WAVE COMPLETE"

	elif wave_in_progress:

		enemy_text = "SPAWNING"


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
		+ "\nWave: "
		+ str(current_wave)
		+ "\nEnemies Remaining: "
		+ str(get_enemies_remaining())
		+ "\nSkeletons: "
		+ str(skeletons.size())
		+ "\nUpgrades: "
		+ str(total_upgrades_selected)
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
