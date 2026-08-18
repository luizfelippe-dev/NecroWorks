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

var skeleton_max_hp: int = 1

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

# O combate acontece em uma faixa controlada da arena.
# Isso impede Enemy/Boss e formação de "arrastarem" uns aos
# outros infinitamente para fora da tela.
const ENEMY_LANE_Y: float = 555.0
const ENEMY_MIN_X: float = 650.0
const ENEMY_MAX_X: float = 1650.0

const SKELETON_COMBAT_MIN_X: float = 80.0
const SKELETON_COMBAT_MAX_X: float = 1500.0
const SKELETON_COMBAT_MIN_Y: float = 300.0
const SKELETON_COMBAT_MAX_Y: float = 810.0

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
# BOSS
# =========================================================

const BOSS_WAVE: int = 20
const BOSS_NAME: String = "THE FOREMAN"

const BOSS_HP: int = 2200
const BOSS_DAMAGE: int = 28
const BOSS_SIZE: float = 140.0

const BOSS_SPECIAL_ATTACK_INTERVAL: float = 4.0
const BOSS_SPECIAL_ATTACK_TARGETS: int = 6
const BOSS_SPECIAL_ATTACK_DAMAGE: int = 35

const BOSS_COLOR: Color = Color(
	0.32,
	0.02,
	0.38,
	1.0
)

var boss_active: bool = false
var boss_special_attack_timer: float = 0.0


# =========================================================
# RUN END
# =========================================================

var run_finished: bool = false
var run_won: bool = false

var run_end_panel: ColorRect = null
var run_end_title_label: Label = null
var run_end_summary_label: Label = null
var restart_run_button: Button = null


# =========================================================
# UPGRADES
# =========================================================

const UPGRADE_SHARPENED_BONES: String = "sharpened_bones"
const UPGRADE_BONE_PLATING: String = "bone_plating"
const UPGRADE_EFFICIENT_RECYCLING: String = "efficient_recycling"
const UPGRADE_RAPID_ASSAULT: String = "rapid_assault"
const UPGRADE_DEATH_MARCH: String = "death_march"
const UPGRADE_MASS_PRODUCTION: String = "mass_production"
const UPGRADE_HEAVY_BONES: String = "heavy_bones"
const UPGRADE_BONE_HARVEST: String = "bone_harvest"
const UPGRADE_REASSEMBLY: String = "reassembly"
const UPGRADE_FINAL_SERVICE: String = "final_service"

const MIN_SKELETON_ATTACK_COOLDOWN: float = 0.20

const BONE_HARVEST_CHANCE_PER_STACK: float = 0.20
const BONE_HARVEST_MAX_CHANCE: float = 1.0
const BONE_HARVEST_BONUS: int = 5

const REASSEMBLY_CHANCE_PER_STACK: float = 0.15
const REASSEMBLY_MAX_CHANCE: float = 0.75
const REASSEMBLY_HP_FRACTION: float = 0.50

const FINAL_SERVICE_DAMAGE_PER_STACK: int = 20

var bone_harvest_chance: float = 0.0
var reassembly_chance: float = 0.0
var final_service_damage: int = 0

var upgrade_counts: Dictionary = {}
var total_upgrades_selected: int = 0
var current_upgrade_choices: Array[String] = []

var upgrade_panel: ColorRect = null
var upgrade_title_label: Label = null
var upgrade_buttons: Array[Button] = []


# =========================================================
# SYNERGIES
# =========================================================

const SYNERGY_RECYCLING_PLANT: String = "recycling_plant"
const SYNERGY_SECOND_SHIFT: String = "second_shift"
const SYNERGY_BONE_ASSEMBLY_LINE: String = "bone_assembly_line"
const SYNERGY_OVERCLOCKED_OSSUARY: String = "overclocked_ossuary"

const ASSEMBLY_LINE_CHANCE: float = 0.25
const OVERCLOCK_DOUBLE_STRIKE_CHANCE: float = 0.20
const SECOND_SHIFT_DAMAGE_MULTIPLIER: float = 0.50

var active_synergies: Dictionary = {}
var synergy_label: Label = null


# =========================================================
# RUN METRICS
# =========================================================

var total_enemies_killed: int = 0
var total_corpses_processed: int = 0
var total_skeletons_created: int = 0
var total_skeletons_lost: int = 0
var total_skeletons_revived: int = 0
var total_bones_earned: int = 0


# =========================================================
# SKELETONS
# =========================================================

var skeletons: Array[Node2D] = []
var corpses: Array[Button] = []

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
	create_synergy_hud()
	create_run_end_ui()


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


	if run_finished:
		return


	check_defeat_condition()


	if run_finished:
		return


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


	if boss_active:

		boss_special_attack_timer = maxf(
			boss_special_attack_timer - delta,
			0.0
		)


		if (
			boss_special_attack_timer <= 0.0
			and not skeletons.is_empty()
		):

			boss_special_attack()

			boss_special_attack_timer = (
				BOSS_SPECIAL_ATTACK_INTERVAL
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


	var distance_to_skeleton: float = absf(
		enemy.position.x
		- closest_skeleton.position.x
	)


	# Enemy/Boss luta em uma lane horizontal.
	# Não perseguimos o Y do Skeleton porque a formação também
	# depende da posição do Enemy. Perseguir nos dois eixos criava
	# um feedback em que os dois lados podiam sair da tela.
	enemy.position.y = ENEMY_LANE_Y


	if distance_to_skeleton > enemy_attack_range:

		var next_enemy_x: float = move_toward(
			enemy.position.x,
			closest_skeleton.position.x,
			enemy_speed * delta
		)


		next_enemy_x = clampf(
			next_enemy_x,
			ENEMY_MIN_X,
			ENEMY_MAX_X
		)


		enemy.position.x = next_enemy_x

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

	boss_active = is_boss_wave(
		current_wave
	)

	if boss_active:

		enemy_max_hp = BOSS_HP
		enemy_damage = BOSS_DAMAGE

		boss_special_attack_timer = (
			BOSS_SPECIAL_ATTACK_INTERVAL
		)

	else:

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

	if boss_active:
		print("BOSS WAVE!")
		print(BOSS_NAME)

	elif is_elite_wave(current_wave):
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

		update_current_enemy_visual_size()

	else:

		spawn_enemy()


	update_wave_ui()
	update_debug_ui()


func get_enemies_for_wave(
	wave_number: int
) -> int:

	if is_boss_wave(wave_number):
		return 1


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
		and wave_number != BOSS_WAVE
		and wave_number % ELITE_WAVE_INTERVAL == 0
	)


func is_boss_wave(
	wave_number: int
) -> bool:

	return (
		wave_number == BOSS_WAVE
	)


func get_current_enemy_color() -> Color:

	if is_boss_wave(current_wave):
		return BOSS_COLOR


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


	# Os slots de spawn continuam persistentes, mas a formação
	# de combate fecha as lacunas quando Skeletons morrem.
	# Assim um Skeleton que originalmente estava numa coluna
	# traseira pode avançar e ocupar a frente da formação.
	var compacted_slot: int = (
		get_compacted_combat_slot(
			slot
		)
	)


	var combat_column: int = int(
		compacted_slot / COMBAT_ROWS
	)


	var slot_inside_column: int = (
		compacted_slot % COMBAT_ROWS
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


	var target_x: float = clampf(
		enemy.position.x
		- horizontal_offset,
		SKELETON_COMBAT_MIN_X,
		SKELETON_COMBAT_MAX_X
	)


	var target_y: float = clampf(
		ENEMY_LANE_Y
		+ vertical_offset,
		SKELETON_COMBAT_MIN_Y,
		SKELETON_COMBAT_MAX_Y
	)


	return Vector2(
		target_x,
		target_y
	)


func get_compacted_combat_slot(
	original_slot: int
) -> int:

	var compacted_slot: int = 0


	for slot_index: int in range(
		MAX_SKELETONS
	):

		if not occupied_skeleton_slots.has(
			slot_index
		):

			continue


		if slot_index == original_slot:

			return compacted_slot


		compacted_slot += 1


	# Fallback defensivo. Normalmente não deve acontecer.
	return original_slot


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

	var closest_horizontal_distance: float = INF

	var closest_vertical_distance: float = INF


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var horizontal_distance: float = absf(
			enemy.position.x
			- current_skeleton.position.x
		)


		var vertical_distance: float = absf(
			ENEMY_LANE_Y
			- current_skeleton.position.y
		)


		if horizontal_distance < closest_horizontal_distance:

			closest_horizontal_distance = (
				horizontal_distance
			)

			closest_vertical_distance = (
				vertical_distance
			)

			closest_skeleton = (
				current_skeleton
			)


		elif (
			is_equal_approx(
				horizontal_distance,
				closest_horizontal_distance
			)
			and vertical_distance
			< closest_vertical_distance
		):

			closest_vertical_distance = (
				vertical_distance
			)

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


	var double_strike_triggered: bool = false


	if (
		has_synergy(
			SYNERGY_OVERCLOCKED_OSSUARY
		)
		and enemy_hp > 0
		and randf()
		< OVERCLOCK_DOUBLE_STRIKE_CHANCE
	):

		enemy_hp -= skeleton_damage

		double_strike_triggered = true


	skeleton_attack_timers[
		attacking_skeleton
	] = skeleton_attack_cooldown


	print(
		"SKELETON ATACOU! | Enemy HP: ",
		enemy_hp,
		" | Skeletons vivos: ",
		skeletons.size()
	)


	if double_strike_triggered:

		print(
			"OVERCLOCKED OSSUARY! DOUBLE STRIKE! +",
			skeleton_damage,
			" damage."
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

	# -----------------------------------------------------
	# REASSEMBLY
	# -----------------------------------------------------

	if (
		reassembly_chance > 0.0
		and randf() < reassembly_chance
	):

		var revived_hp: int = int(
			ceil(
				float(skeleton_max_hp)
				* REASSEMBLY_HP_FRACTION
			)
		)

		if revived_hp < 1:
			revived_hp = 1


		skeleton_hps[
			target
		] = revived_hp


		skeleton_attack_timers[
			target
		] = skeleton_attack_cooldown


		total_skeletons_revived += 1


		print(
			"REASSEMBLY! Skeleton reviveu com ",
			revived_hp,
			" HP."
		)


		# -------------------------------------------------
		# SYNERGY: SECOND SHIFT
		# -------------------------------------------------

		if (
			has_synergy(
				SYNERGY_SECOND_SHIFT
			)
			and final_service_damage > 0
			and is_instance_valid(enemy)
		):

			var second_shift_damage: int = int(
				round(
					float(final_service_damage)
					* SECOND_SHIFT_DAMAGE_MULTIPLIER
				)
			)


			if second_shift_damage < 1:

				second_shift_damage = 1


			enemy_hp -= second_shift_damage


			print(
				"SECOND SHIFT! O Skeleton reviveu e ainda causou ",
				second_shift_damage,
				" damage. | Enemy HP: ",
				enemy_hp
			)


			if enemy_hp <= 0:

				print(
					"SECOND SHIFT MATOU O ENEMY!"
				)

				kill_enemy()


		update_bones_ui()
		update_debug_ui()

		return


	print(
		"SKELETON MORREU!"
	)


	total_skeletons_lost += 1


	# -----------------------------------------------------
	# FINAL SERVICE
	# -----------------------------------------------------

	var final_service_killed_enemy: bool = false


	if (
		final_service_damage > 0
		and is_instance_valid(enemy)
	):

		enemy_hp -= final_service_damage


		print(
			"FINAL SERVICE! ",
			final_service_damage,
			" de dano. | Enemy HP: ",
			enemy_hp
		)


		if enemy_hp <= 0:
			final_service_killed_enemy = true


	# -----------------------------------------------------
	# REMOVER SKELETON
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


	if final_service_killed_enemy:

		print(
			"FINAL SERVICE MATOU O ENEMY!"
		)

		kill_enemy()


# =========================================================
# MATAR ENEMY / PROGREDIR WAVE
# =========================================================

func kill_enemy() -> void:

	if not is_instance_valid(enemy):
		return


	print(
		"INIMIGO MORREU!"
	)


	total_enemies_killed += 1


	var defeated_boss: bool = boss_active


	if defeated_boss:

		print("")
		print("##############################")
		print(BOSS_NAME, " DEFEATED!")
		print("##############################")
		print("")


	var dead_enemy: Node2D = enemy


	var death_position: Vector2 = (
		dead_enemy.position
	)


	enemy = null


	if defeated_boss:
		boss_active = false


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
	# BOSS DERROTADO = VICTORY
	# =====================================================

	if defeated_boss:

		wave_in_progress = false
		wave_transition_in_progress = false

		finish_run(
			true
		)

		return


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

	update_current_enemy_visual_size()

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
# BOSS
# =========================================================

func update_current_enemy_visual_size() -> void:

	if not is_instance_valid(enemy):
		return


	var visual_node: Node = (
		enemy.get_node_or_null(
			"DebugVisual"
		)
	)


	var visual: Polygon2D = (
		visual_node as Polygon2D
	)


	if visual == null:
		return


	var target_size: float = UNIT_SIZE


	if boss_active:
		target_size = BOSS_SIZE


	var half_size: float = (
		target_size / 2.0
	)


	visual.polygon = PackedVector2Array(
		[
			Vector2(-half_size, -half_size),
			Vector2(half_size, -half_size),
			Vector2(half_size, half_size),
			Vector2(-half_size, half_size)
		]
	)


func boss_special_attack() -> void:

	if not boss_active:
		return


	if not is_instance_valid(enemy):
		return


	if skeletons.is_empty():
		return


	var valid_targets: Array[Node2D] = []


	for current_skeleton: Node2D in skeletons:

		if is_instance_valid(
			current_skeleton
		):

			valid_targets.append(
				current_skeleton
			)


	valid_targets.shuffle()


	var target_count: int = min(
		BOSS_SPECIAL_ATTACK_TARGETS,
		valid_targets.size()
	)


	if target_count <= 0:
		return


	print("")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print(
		BOSS_NAME,
		" USED INDUSTRIAL CRUSH!"
	)
	print(
		"Targets: ",
		target_count,
		" | Damage: ",
		BOSS_SPECIAL_ATTACK_DAMAGE
	)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")


	var targets_to_damage: Array[Node2D] = []


	for index: int in range(
		target_count
	):

		targets_to_damage.append(
			valid_targets[index]
		)


	for target: Node2D in targets_to_damage:

		if not is_instance_valid(target):
			continue


		if not skeleton_hps.has(target):
			continue


		var current_hp: int = int(
			skeleton_hps[target]
		)


		current_hp -= (
			BOSS_SPECIAL_ATTACK_DAMAGE
		)


		skeleton_hps[
			target
		] = current_hp


		print(
			"BOSS AOE | Skeleton HP: ",
			current_hp
		)


		if current_hp <= 0:

			kill_skeleton(
				target
			)


			if not is_instance_valid(enemy):
				return


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


	corpses.append(
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

	if run_finished:
		return


	if not is_instance_valid(corpse):
		return


	var bones_gained: int = bones_per_corpse

	var harvest_triggered: bool = false

	var harvest_bonus: int = (
		BONE_HARVEST_BONUS
	)


	if has_synergy(
		SYNERGY_RECYCLING_PLANT
	):

		harvest_bonus *= 2


	if (
		bone_harvest_chance > 0.0
		and randf() < bone_harvest_chance
	):

		bones_gained += harvest_bonus

		harvest_triggered = true


	bones += bones_gained

	total_bones_earned += bones_gained

	total_corpses_processed += 1


	update_bones_ui()


	print(
		"CADÁVER PROCESSADO!"
	)

	print(
		"+",
		bones_gained,
		" BONES"
	)


	if harvest_triggered:

		print(
			"BONE HARVEST! Bônus de +",
			harvest_bonus,
			" Bones."
		)


		if has_synergy(
			SYNERGY_RECYCLING_PLANT
		):

			print(
				"RECYCLING PLANT! Bone Harvest bonus doubled."
			)


	print(
		"TOTAL DE BONES: ",
		bones
	)


	corpses.erase(
		corpse
	)


	corpse.queue_free()


	# -----------------------------------------------------
	# SYNERGY: BONE ASSEMBLY LINE
	# -----------------------------------------------------

	if (
		has_synergy(
			SYNERGY_BONE_ASSEMBLY_LINE
		)
		and randf() < ASSEMBLY_LINE_CHANCE
	):

		var built: bool = (
			create_free_skeleton(
				"BONE ASSEMBLY LINE"
			)
		)


		if built:

			print(
				"BONE ASSEMBLY LINE! FREE SKELETON PRODUCED."
			)


	update_debug_ui()


# =========================================================
# CRIAR SKELETON
# =========================================================

func create_skeleton() -> void:

	if run_finished:
		return


	if bones < skeleton_cost:

		print(
			"BONES INSUFICIENTES!"
		)

		return


	create_skeleton_internal(
		false,
		"MANUAL"
	)


func create_free_skeleton(
	source: String
) -> bool:

	return create_skeleton_internal(
		true,
		source
	)


func create_skeleton_internal(
	is_free: bool,
	source: String
) -> bool:

	var free_slot: int = (
		get_free_skeleton_slot()
	)


	if free_slot == -1:

		if not is_free:

			print(
				"LIMITE DE SKELETONS ATINGIDO!"
			)

		return false


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

		return false


	if not is_free:

		if bones < skeleton_cost:

			skeleton_node.queue_free()

			return false


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


	total_skeletons_created += 1


	update_bones_ui()
	update_debug_ui()


	if is_free:

		print(
			"NOVO SKELETON GRATUITO CRIADO!"
		)

		print(
			"ORIGEM: ",
			source
		)

	else:

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


	return true


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

	upgrade_panel.position = Vector2(
		300.0,
		220.0
	)

	upgrade_panel.size = Vector2(
		1320.0,
		500.0
	)

	upgrade_panel.color = Color(
		0.04,
		0.04,
		0.04,
		0.96
	)

	upgrade_panel.z_index = 500

	# O painel em si não precisa bloquear clique.
	# Os Buttons filhos continuam clicáveis.
	upgrade_panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	add_child(
		upgrade_panel
	)


	upgrade_title_label = Label.new()

	upgrade_title_label.name = "UpgradeTitle"

	upgrade_title_label.position = Vector2(
		40.0,
		25.0
	)

	upgrade_title_label.size = Vector2(
		1240.0,
		50.0
	)

	upgrade_title_label.text = (
		"SELECT AN UPGRADE"
	)


	upgrade_panel.add_child(
		upgrade_title_label
	)


	for index: int in range(3):

		create_upgrade_button(
			index
		)


	upgrade_panel.visible = false


func create_upgrade_button(
	index: int
) -> void:

	var button: Button = Button.new()

	button.name = (
		"UpgradeButton"
		+ str(index + 1)
	)

	button.position = Vector2(
		40.0
		+ (
			float(index)
			* 420.0
		),
		100.0
	)

	button.size = Vector2(
		390.0,
		340.0
	)


	button.pressed.connect(
		select_upgrade_by_index.bind(
			index
		)
	)


	upgrade_panel.add_child(
		button
	)


	upgrade_buttons.append(
		button
	)


func get_upgrade_pool() -> Array[String]:

	var pool: Array[String] = [
		UPGRADE_SHARPENED_BONES,
		UPGRADE_BONE_PLATING,
		UPGRADE_EFFICIENT_RECYCLING,
		UPGRADE_RAPID_ASSAULT,
		UPGRADE_DEATH_MARCH,
		UPGRADE_MASS_PRODUCTION,
		UPGRADE_HEAVY_BONES,
		UPGRADE_BONE_HARVEST,
		UPGRADE_REASSEMBLY,
		UPGRADE_FINAL_SERVICE
	]


	# Upgrades com limite deixam de aparecer
	# quando já atingiram seu teto.

	if skeleton_cost <= 1:

		pool.erase(
			UPGRADE_MASS_PRODUCTION
		)


	if (
		skeleton_attack_cooldown
		<= MIN_SKELETON_ATTACK_COOLDOWN
	):

		pool.erase(
			UPGRADE_RAPID_ASSAULT
		)


	if (
		bone_harvest_chance
		>= BONE_HARVEST_MAX_CHANCE
	):

		pool.erase(
			UPGRADE_BONE_HARVEST
		)


	if (
		reassembly_chance
		>= REASSEMBLY_MAX_CHANCE
	):

		pool.erase(
			UPGRADE_REASSEMBLY
		)


	return pool


func roll_upgrade_choices() -> void:

	current_upgrade_choices.clear()


	var pool: Array[String] = (
		get_upgrade_pool()
	)


	pool.shuffle()


	var choices_to_take: int = 3


	if pool.size() < choices_to_take:

		choices_to_take = pool.size()


	for index: int in range(
		choices_to_take
	):

		current_upgrade_choices.append(
			pool[index]
		)


func show_upgrade_selection() -> void:

	if upgrade_panel == null:
		return


	if not wave_transition_in_progress:
		return


	roll_upgrade_choices()
	update_upgrade_ui()


	upgrade_panel.visible = true


	print("")
	print("------------------------------")
	print("SELECT AN UPGRADE")


	for index: int in range(
		current_upgrade_choices.size()
	):

		var upgrade_id: String = (
			current_upgrade_choices[
				index
			]
		)


		print(
			index + 1,
			". ",
			get_upgrade_name(
				upgrade_id
			)
		)


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


	for index: int in range(
		upgrade_buttons.size()
	):

		var button: Button = (
			upgrade_buttons[index]
		)


		if (
			index
			>= current_upgrade_choices.size()
		):

			button.visible = false

			continue


		button.visible = true


		var upgrade_id: String = (
			current_upgrade_choices[
				index
			]
		)


		button.text = (
			get_upgrade_card_text(
				upgrade_id
			)
		)


func get_upgrade_card_text(
	upgrade_id: String
) -> String:

	return (
		get_upgrade_name(
			upgrade_id
		)
		.to_upper()
		+ "\n\n"
		+ get_upgrade_description(
			upgrade_id
		)
		+ "\n\n"
		+ get_upgrade_status(
			upgrade_id
		)
		+ "\nTaken: "
		+ str(
			get_upgrade_count(
				upgrade_id
			)
		)
	)


func get_upgrade_count(
	upgrade_id: String
) -> int:

	return int(
		upgrade_counts.get(
			upgrade_id,
			0
		)
	)


func select_upgrade_by_index(
	index: int
) -> void:

	if not wave_transition_in_progress:
		return


	if index < 0:
		return


	if (
		index
		>= current_upgrade_choices.size()
	):

		return


	var upgrade_id: String = (
		current_upgrade_choices[
			index
		]
	)


	select_upgrade(
		upgrade_id
	)


func select_upgrade(
	upgrade_id: String
) -> void:

	if run_finished:
		return


	if not wave_transition_in_progress:
		return


	apply_upgrade(
		upgrade_id
	)


	var previous_count: int = (
		get_upgrade_count(
			upgrade_id
		)
	)


	upgrade_counts[
		upgrade_id
	] = previous_count + 1


	total_upgrades_selected += 1


	check_synergy_unlocks()


	print("")
	print("==============================")
	print(
		"UPGRADE SELECTED: ",
		get_upgrade_name(
			upgrade_id
		)
	)

	print(
		"Skeleton DMG: ",
		skeleton_damage,
		" | Max HP: ",
		skeleton_max_hp,
		" | Cooldown: ",
		skeleton_attack_cooldown,
		" | Speed: ",
		skeleton_speed
	)

	print(
		"Skeleton Cost: ",
		skeleton_cost,
		" | Bones/Corpse: ",
		bones_per_corpse
	)

	print(
		"Bone Harvest: ",
		int(
			round(
				bone_harvest_chance
				* 100.0
			)
		),
		"% | Reassembly: ",
		int(
			round(
				reassembly_chance
				* 100.0
			)
		),
		"% | Final Service: ",
		final_service_damage
	)

	print("==============================")


	hide_upgrade_selection()


	wave_transition_in_progress = false

	current_wave += 1


	start_wave(
		current_wave
	)


func apply_upgrade(
	upgrade_id: String
) -> void:

	match upgrade_id:

		UPGRADE_SHARPENED_BONES:

			var new_damage: int = int(
				ceil(
					float(skeleton_damage)
					* 1.25
				)
			)


			if new_damage <= skeleton_damage:

				new_damage = (
					skeleton_damage
					+ 1
				)


			skeleton_damage = new_damage


		UPGRADE_BONE_PLATING:

			skeleton_max_hp += 25


			for current_skeleton: Node2D in skeletons:

				if not is_instance_valid(
					current_skeleton
				):
					continue


				if not skeleton_hps.has(
					current_skeleton
				):
					continue


				var current_hp: int = int(
					skeleton_hps[
						current_skeleton
					]
				)


				skeleton_hps[
					current_skeleton
				] = current_hp + 25


		UPGRADE_EFFICIENT_RECYCLING:

			bones_per_corpse += 2


		UPGRADE_RAPID_ASSAULT:

			skeleton_attack_cooldown = maxf(
				skeleton_attack_cooldown
				* 0.85,
				MIN_SKELETON_ATTACK_COOLDOWN
			)


		UPGRADE_DEATH_MARCH:

			skeleton_speed *= 1.20


		UPGRADE_MASS_PRODUCTION:

			skeleton_cost -= 1


			if skeleton_cost < 1:

				skeleton_cost = 1


		UPGRADE_HEAVY_BONES:

			var heavy_damage: int = int(
				ceil(
					float(skeleton_damage)
					* 1.50
				)
			)


			if heavy_damage <= skeleton_damage:

				heavy_damage = (
					skeleton_damage
					+ 1
				)


			skeleton_damage = heavy_damage

			# -20% attack speed equivale a
			# aumentar o intervalo entre ataques em 25%.
			skeleton_attack_cooldown *= 1.25


		UPGRADE_BONE_HARVEST:

			bone_harvest_chance = minf(
				bone_harvest_chance
				+ BONE_HARVEST_CHANCE_PER_STACK,
				BONE_HARVEST_MAX_CHANCE
			)


		UPGRADE_REASSEMBLY:

			reassembly_chance = minf(
				reassembly_chance
				+ REASSEMBLY_CHANCE_PER_STACK,
				REASSEMBLY_MAX_CHANCE
			)


		UPGRADE_FINAL_SERVICE:

			final_service_damage += (
				FINAL_SERVICE_DAMAGE_PER_STACK
			)


		_:

			push_error(
				"Upgrade desconhecido: "
				+ upgrade_id
			)


	update_bones_ui()
	update_debug_ui()


func get_upgrade_name(
	upgrade_id: String
) -> String:

	match upgrade_id:

		UPGRADE_SHARPENED_BONES:
			return "Sharpened Bones"

		UPGRADE_BONE_PLATING:
			return "Bone Plating"

		UPGRADE_EFFICIENT_RECYCLING:
			return "Efficient Recycling"

		UPGRADE_RAPID_ASSAULT:
			return "Rapid Assault"

		UPGRADE_DEATH_MARCH:
			return "Death March"

		UPGRADE_MASS_PRODUCTION:
			return "Mass Production"

		UPGRADE_HEAVY_BONES:
			return "Heavy Bones"

		UPGRADE_BONE_HARVEST:
			return "Bone Harvest"

		UPGRADE_REASSEMBLY:
			return "Reassembly"

		UPGRADE_FINAL_SERVICE:
			return "Final Service"

		_:
			return "Unknown Upgrade"


func get_upgrade_description(
	upgrade_id: String
) -> String:

	match upgrade_id:

		UPGRADE_SHARPENED_BONES:
			return "Skeleton Damage +25%"

		UPGRADE_BONE_PLATING:
			return (
				"Skeleton Max HP +25"
				+ "\nExisting Skeletons gain +25 HP"
			)

		UPGRADE_EFFICIENT_RECYCLING:
			return "Corpses generate +2 Bones"

		UPGRADE_RAPID_ASSAULT:
			return "Skeleton Attack Speed +15%"

		UPGRADE_DEATH_MARCH:
			return "Skeleton Movement Speed +20%"

		UPGRADE_MASS_PRODUCTION:
			return "Skeleton cost -1 Bone"

		UPGRADE_HEAVY_BONES:
			return (
				"Skeleton Damage +50%"
				+ "\nAttack Speed -20%"
			)

		UPGRADE_BONE_HARVEST:
			return (
				"+20% chance when processing a Corpse"
				+ "\nto gain +5 bonus Bones"
			)

		UPGRADE_REASSEMBLY:
			return (
				"+15% chance for a dead Skeleton"
				+ "\nto revive with 50% HP"
			)

		UPGRADE_FINAL_SERVICE:
			return (
				"When a Skeleton dies,"
				+ "\ndeal +20 damage to the Enemy"
			)

		_:
			return "Unknown effect"


func get_upgrade_status(
	upgrade_id: String
) -> String:

	match upgrade_id:

		UPGRADE_SHARPENED_BONES:
			return (
				"Current DMG: "
				+ str(skeleton_damage)
			)

		UPGRADE_BONE_PLATING:
			return (
				"Current Max HP: "
				+ str(skeleton_max_hp)
			)

		UPGRADE_EFFICIENT_RECYCLING:
			return (
				"Current Bones/Corpse: "
				+ str(bones_per_corpse)
			)

		UPGRADE_RAPID_ASSAULT:
			return (
				"Current Cooldown: "
				+ str(
					snappedf(
						skeleton_attack_cooldown,
						0.01
					)
				)
				+ "s"
			)

		UPGRADE_DEATH_MARCH:
			return (
				"Current Move Speed: "
				+ str(
					int(
						round(
							skeleton_speed
						)
					)
				)
			)

		UPGRADE_MASS_PRODUCTION:
			return (
				"Current Skeleton Cost: "
				+ str(skeleton_cost)
			)

		UPGRADE_HEAVY_BONES:
			return (
				"DMG "
				+ str(skeleton_damage)
				+ " | Cooldown "
				+ str(
					snappedf(
						skeleton_attack_cooldown,
						0.01
					)
				)
				+ "s"
			)

		UPGRADE_BONE_HARVEST:
			return (
				"Current Chance: "
				+ str(
					int(
						round(
							bone_harvest_chance
								* 100.0
						)
					)
				)
				+ "%"
			)

		UPGRADE_REASSEMBLY:
			return (
				"Current Chance: "
				+ str(
					int(
						round(
							reassembly_chance
								* 100.0
						)
					)
				)
				+ "%"
			)

		UPGRADE_FINAL_SERVICE:
			return (
				"Current Death Damage: "
				+ str(
					final_service_damage
				)
			)

		_:
			return ""


# =========================================================
# SYNERGY SYSTEM
# =========================================================

func check_synergy_unlocks() -> void:

	if (
		get_upgrade_count(
			UPGRADE_EFFICIENT_RECYCLING
		) > 0
		and get_upgrade_count(
			UPGRADE_BONE_HARVEST
		) > 0
	):

		unlock_synergy(
			SYNERGY_RECYCLING_PLANT
		)


	if (
		get_upgrade_count(
			UPGRADE_REASSEMBLY
		) > 0
		and get_upgrade_count(
			UPGRADE_FINAL_SERVICE
		) > 0
	):

		unlock_synergy(
			SYNERGY_SECOND_SHIFT
		)


	if (
		get_upgrade_count(
			UPGRADE_MASS_PRODUCTION
		) > 0
		and get_upgrade_count(
			UPGRADE_EFFICIENT_RECYCLING
		) > 0
	):

		unlock_synergy(
			SYNERGY_BONE_ASSEMBLY_LINE
		)


	if (
		get_upgrade_count(
			UPGRADE_HEAVY_BONES
		) > 0
		and get_upgrade_count(
			UPGRADE_RAPID_ASSAULT
		) > 0
	):

		unlock_synergy(
			SYNERGY_OVERCLOCKED_OSSUARY
		)


func unlock_synergy(
	synergy_id: String
) -> void:

	if has_synergy(
		synergy_id
	):

		return


	active_synergies[
		synergy_id
	] = true


	print("")
	print("################################")
	print(
		"SYNERGY UNLOCKED: ",
		get_synergy_name(
			synergy_id
		)
	)
	print(
		get_synergy_description(
			synergy_id
		)
	)
	print("################################")
	print("")


	update_synergy_ui()
	update_debug_ui()


func has_synergy(
	synergy_id: String
) -> bool:

	return bool(
		active_synergies.get(
			synergy_id,
			false
		)
	)


func get_synergy_name(
	synergy_id: String
) -> String:

	match synergy_id:

		SYNERGY_RECYCLING_PLANT:
			return "Recycling Plant"

		SYNERGY_SECOND_SHIFT:
			return "Second Shift"

		SYNERGY_BONE_ASSEMBLY_LINE:
			return "Bone Assembly Line"

		SYNERGY_OVERCLOCKED_OSSUARY:
			return "Overclocked Ossuary"

		_:
			return "Unknown Synergy"


func get_synergy_description(
	synergy_id: String
) -> String:

	match synergy_id:

		SYNERGY_RECYCLING_PLANT:
			return (
				"Efficient Recycling + Bone Harvest"
				+ "\nBone Harvest bonus is doubled."
			)

		SYNERGY_SECOND_SHIFT:
			return (
				"Reassembly + Final Service"
				+ "\nA successful revive also deals 50% Final Service damage."
			)

		SYNERGY_BONE_ASSEMBLY_LINE:
			return (
				"Mass Production + Efficient Recycling"
				+ "\n25% chance to produce a free Skeleton when processing a Corpse."
			)

		SYNERGY_OVERCLOCKED_OSSUARY:
			return (
				"Heavy Bones + Rapid Assault"
				+ "\nSkeleton attacks gain a 20% chance to strike twice."
			)

		_:
			return ""


func create_synergy_hud() -> void:

	synergy_label = Label.new()

	synergy_label.name = "SynergyLabel"

	synergy_label.position = Vector2(
		1430.0,
		40.0
	)

	synergy_label.size = Vector2(
		450.0,
		300.0
	)

	synergy_label.z_index = 100


	add_child(
		synergy_label
	)


	update_synergy_ui()


func update_synergy_ui() -> void:

	if synergy_label == null:
		return


	var text_value: String = (
		"ACTIVE SYNERGIES"
	)


	if active_synergies.is_empty():

		text_value += "\nNone"

	else:

		var synergy_order: Array[String] = [
			SYNERGY_RECYCLING_PLANT,
			SYNERGY_SECOND_SHIFT,
			SYNERGY_BONE_ASSEMBLY_LINE,
			SYNERGY_OVERCLOCKED_OSSUARY
		]


		for synergy_id: String in synergy_order:

			if not has_synergy(
				synergy_id
			):

				continue


			text_value += (
				"\n- "
				+ get_synergy_name(
					synergy_id
				)
			)


	synergy_label.text = text_value


# =========================================================
# DEFEAT CONDITION
# =========================================================

func check_defeat_condition() -> void:

	if run_finished:
		return


	# Não existe derrota durante a escolha de upgrade.
	# Uma escolha ainda pode alterar custo/economia antes
	# da próxima Wave começar.
	if wave_transition_in_progress:
		return


	# Só avaliamos derrota dentro de uma Wave ativa.
	if not wave_in_progress:
		return


	# Se ainda existe algum Skeleton vivo, a operação continua.
	if not skeletons.is_empty():
		return


	cleanup_invalid_corpses()


	# Ainda existe matéria-prima processável.
	# O jogador pode recuperar Bones e reconstruir.
	if not corpses.is_empty():
		return


	# Ainda existem Bones suficientes para produzir
	# pelo menos um Skeleton.
	if bones >= skeleton_cost:
		return


	print("")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("NO VIABLE UNDEAD PRODUCTION REMAINS")
	print(
		"Skeletons: 0 | Corpses: 0 | Bones: ",
		bones,
		" / ",
		skeleton_cost
	)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("")


	finish_run(
		false
	)


func cleanup_invalid_corpses() -> void:

	var valid_corpses: Array[Button] = []


	for corpse: Button in corpses:

		if is_instance_valid(
			corpse
		):

			valid_corpses.append(
				corpse
			)


	corpses = valid_corpses


# =========================================================
# RUN END / VICTORY
# =========================================================

func create_run_end_ui() -> void:

	run_end_panel = ColorRect.new()

	run_end_panel.name = "RunEndPanel"

	run_end_panel.position = Vector2(
		0.0,
		0.0
	)

	run_end_panel.size = Vector2(
		1920.0,
		1080.0
	)

	run_end_panel.color = Color(
		0.015,
		0.015,
		0.015,
		0.96
	)

	run_end_panel.z_index = 1000

	run_end_panel.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)


	add_child(
		run_end_panel
	)


	run_end_title_label = Label.new()

	run_end_title_label.name = "RunEndTitle"

	run_end_title_label.position = Vector2(
		510.0,
		135.0
	)

	run_end_title_label.size = Vector2(
		900.0,
		120.0
	)

	run_end_title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	run_end_title_label.text = (
		"RUN COMPLETE"
	)


	run_end_panel.add_child(
		run_end_title_label
	)


	run_end_summary_label = Label.new()

	run_end_summary_label.name = "RunEndSummary"

	run_end_summary_label.position = Vector2(
		560.0,
		285.0
	)

	run_end_summary_label.size = Vector2(
		800.0,
		500.0
	)

	run_end_summary_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	run_end_summary_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_TOP
	)


	run_end_panel.add_child(
		run_end_summary_label
	)


	restart_run_button = Button.new()

	restart_run_button.name = "RestartRunButton"

	restart_run_button.position = Vector2(
		760.0,
		825.0
	)

	restart_run_button.size = Vector2(
		400.0,
		90.0
	)

	restart_run_button.text = (
		"RESTART RUN"
	)

	restart_run_button.pressed.connect(
		restart_run
	)


	run_end_panel.add_child(
		restart_run_button
	)


	run_end_panel.visible = false


func finish_run(
	victory: bool
) -> void:

	if run_finished:
		return


	run_finished = true
	run_won = victory

	boss_active = false
	wave_in_progress = false
	wave_transition_in_progress = false


	hide_upgrade_selection()


	create_skeleton_button.disabled = true


	if victory:

		print("")
		print("================================")
		print("PRODUCTION TARGET ACHIEVED")
		print("NECROWORKS RUN COMPLETE")
		print("================================")
		print("")

	else:

		print("")
		print("================================")
		print("OPERATION TERMINATED")
		print("NECROWORKS RUN FAILED")
		print("================================")
		print("")


	show_run_end_screen()


func show_run_end_screen() -> void:

	if run_end_panel == null:
		return


	if run_end_title_label == null:
		return


	if run_end_summary_label == null:
		return


	if run_won:

		run_end_title_label.text = (
			"PRODUCTION TARGET ACHIEVED"
			+ "\nTHE FOREMAN HAS BEEN TERMINATED"
		)

	else:

		run_end_title_label.text = (
			"OPERATION TERMINATED"
			+ "\nPRODUCTION LINE COLLAPSED"
		)


	run_end_summary_label.text = (
		"NECROWORKS — RUN SUMMARY"
		+ "\n\nWave Reached: "
		+ str(current_wave)
		+ "\nEnemies Killed: "
		+ str(total_enemies_killed)
		+ "\nCorpses Processed: "
		+ str(total_corpses_processed)
		+ "\nCorpses Remaining: "
		+ str(corpses.size())
		+ "\nSkeletons Built: "
		+ str(total_skeletons_created)
		+ "\nSkeletons Lost: "
		+ str(total_skeletons_lost)
		+ "\nSkeletons Revived: "
		+ str(total_skeletons_revived)
		+ "\nBones Earned: "
		+ str(total_bones_earned)
		+ "\nBones Remaining: "
		+ str(bones)
		+ "\nArmy Remaining: "
		+ str(skeletons.size())
		+ "\nUpgrades Selected: "
		+ str(total_upgrades_selected)
		+ "\nSynergies Unlocked: "
		+ str(active_synergies.size())
		+ "\n\n"
		+ get_run_result_message()
		+ "\n\n"
		+ get_run_synergy_summary()
	)


	run_end_panel.visible = true


func get_run_result_message() -> String:

	if run_won:

		return (
			"Result: Production target achieved."
		)


	return (
		"Result: No Skeletons, no Corpses, "
		+ "and insufficient Bones to rebuild."
	)


func get_run_synergy_summary() -> String:

	if active_synergies.is_empty():

		return "Active Synergies: None"


	var result: String = (
		"Active Synergies:"
	)


	var synergy_order: Array[String] = [
		SYNERGY_RECYCLING_PLANT,
		SYNERGY_SECOND_SHIFT,
		SYNERGY_BONE_ASSEMBLY_LINE,
		SYNERGY_OVERCLOCKED_OSSUARY
	]


	for synergy_id: String in synergy_order:

		if not has_synergy(
			synergy_id
		):

			continue


		result += (
			"\n- "
			+ get_synergy_name(
				synergy_id
			)
		)


	return result


func restart_run() -> void:

	print("")
	print("==============================")
	print("RESTARTING NECROWORKS RUN...")
	print("==============================")


	get_tree().reload_current_scene()


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


	if run_finished:

		if run_won:
			wave_label.text = (
				"RUN COMPLETE"
				+ "\nVICTORY"
			)

		else:
			wave_label.text = (
				"RUN COMPLETE"
				+ "\nDEFEAT"
			)

		return


	var wave_title: String = (
		"WAVE "
		+ str(current_wave)
	)


	if is_boss_wave(current_wave):

		wave_title += (
			" - BOSS: "
			+ BOSS_NAME
		)

	elif is_elite_wave(current_wave):

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
		650.0,
		380.0
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

			var distance: float = absf(
				enemy.position.x
				- closest.position.x
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
		+ "\nCorpses: "
		+ str(corpses.size())
		+ "\nCan Rebuild: "
		+ str(
			bones >= skeleton_cost
			or not corpses.is_empty()
		)
		+ "\nUpgrades: "
		+ str(total_upgrades_selected)
		+ "\nSynergies: "
		+ str(active_synergies.size())
		+ "\nBoss Active: "
		+ str(boss_active)
		+ "\nRun Finished: "
		+ str(run_finished)
		+ "\nEnemy: "
		+ enemy_text
		+ "\nClosest X distance: "
		+ closest_distance_text
		+ "\n--- RUN METRICS ---"
		+ "\nEnemies Killed: "
		+ str(total_enemies_killed)
		+ "\nCorpses Processed: "
		+ str(total_corpses_processed)
		+ "\nSkeletons Built: "
		+ str(total_skeletons_created)
		+ "\nSkeletons Lost: "
		+ str(total_skeletons_lost)
		+ "\nSkeletons Revived: "
		+ str(total_skeletons_revived)
		+ "\nBones Earned: "
		+ str(total_bones_earned)
	)


# =========================================================
# BONES UI
# =========================================================

func update_bones_ui() -> void:

	bones_label.text = (
		"Bones: "
		+ str(bones)
		+ " | Skeleton Cost: "
		+ str(skeleton_cost)
	)


	var full: bool = (
		skeletons.size()
		>= MAX_SKELETONS
	)


	create_skeleton_button.disabled = (
		bones < skeleton_cost
		or full
	)
