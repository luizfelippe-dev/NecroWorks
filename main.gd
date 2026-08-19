extends Node2D


signal corpse_processing_feedback_started(
	directive: String,
	bones_gained: int,
	flesh_gained: int
)
signal batch_production_completed(
	unit_type: String,
	quantity: int,
	total_cost: int
)
signal army_doctrine_changed(configuration: Dictionary)


func _notification(what: int) -> void:

	if what != NOTIFICATION_TRANSLATION_CHANGED:
		return


	if not is_node_ready():
		return


	refresh_localized_ui()


func refresh_localized_ui() -> void:

	if factory_title_label != null:
		factory_title_label.text = tr("FACTORY_PRODUCTION_LINE")


	update_bones_ui()
	update_metrics_ui()
	refresh_army_doctrine_status()
	update_wave_ui()
	update_synergy_ui()
	refresh_world_localization()
	update_factory_panel_ui()
	update_army_doctrine_ui()


func refresh_world_localization() -> void:

	for current_enemy: Node2D in enemies:
		if not is_instance_valid(current_enemy):
			continue


		var identity_label: Label = current_enemy.get_node_or_null(
			"IdentityLabel"
		) as Label


		if identity_label != null:
			identity_label.text = get_enemy_display_name(
				str(enemy_types.get(current_enemy, "human_warrior"))
			)


	for corpse: Button in corpses:
		if is_instance_valid(corpse):
			corpse.text = (
				tr("CORPSE_QUEUED")
				if is_corpse_queued(corpse)
				else tr("CORPSE_LABEL")
			)


# =========================================================
# NÓS DA CENA
# =========================================================

@onready var initial_skeleton: Node2D = $Skeleton
@onready var initial_enemy: Node2D = $Enemy

@onready var bones_label: Label = $BonesLabel
@onready var create_skeleton_button: Button = $CreateSkeletonButton

var create_zombie_button: Button = null
var production_quantity_selector: SpinBox = null


# =========================================================
# CENAS
# =========================================================

var corpse_scene: PackedScene = preload(
	"res://corpse.tscn"
)
var skeleton_scene: PackedScene = preload(
	"res://skeleton.tscn"
)
var enemy_scene: PackedScene = preload(
	"res://enemy.tscn"
)
const UNIT_HEALTH_BAR_SCRIPT: Script = preload(
	"res://scripts/ui/unit_health_bar.gd"
)
const ENEMY_WAVE_POLICY: Script = preload(
	"res://scripts/game/enemy_wave_policy.gd"
)
const ENEMY_ARCHETYPE_CATALOG: Script = preload(
	"res://scripts/game/enemy_archetype_catalog.gd"
)
const PROCESSING_DIRECTIVE_POLICY: Script = preload(
	"res://scripts/economy/processing_directive_policy.gd"
)
const ARMY_DOCTRINE_POLICY: Script = preload(
	"res://scripts/factory/army_doctrine_policy.gd"
)
const UNIT_SPRITE_CATALOG: Script = preload(
	"res://scripts/visual/unit_sprite_catalog.gd"
)
const CORPSE_PROCESSING_FEEDBACK_SCRIPT: Script = preload(
	"res://scripts/visual/corpse_processing_feedback.gd"
)


# =========================================================
# ZOMBIE
# =========================================================

func get_selected_production_quantity() -> int:

	if production_quantity_selector == null:
		return 1


	return clampi(
		int(round(production_quantity_selector.value)),
		1,
		MAX_UNDEAD
	)


func get_available_undead_capacity() -> int:

	return maxi(MAX_UNDEAD - get_total_undead_count(), 0)


func create_skeleton_batch_from_ui() -> void:

	create_skeleton_batch(get_selected_production_quantity())


func create_zombie_batch_from_ui() -> void:

	create_zombie_batch(get_selected_production_quantity())


func create_skeleton_batch(quantity: int) -> int:

	if quantity < 1 or quantity > MAX_UNDEAD:
		return 0


	var requested_quantity: int = quantity
	var total_cost: int = requested_quantity * skeleton_cost


	if run_finished:
		return 0


	if requested_quantity > get_available_undead_capacity():
		return 0


	if bones < total_cost:
		return 0


	var produced: int = 0


	for _unit: int in range(requested_quantity):
		if not create_skeleton_internal(false, "MANUAL BATCH"):
			break


		produced += 1


	if produced == requested_quantity:
		batch_production_completed.emit(
			"skeleton",
			produced,
			total_cost
		)


	update_bones_ui()
	return produced


func create_zombie_batch(quantity: int) -> int:

	if quantity < 1 or quantity > MAX_UNDEAD:
		return 0


	var requested_quantity: int = quantity
	var total_cost: int = requested_quantity * zombie_cost


	if run_finished:
		return 0


	if requested_quantity > get_available_undead_capacity():
		return 0


	if flesh < total_cost:
		return 0


	var initial_zombie_count: int = zombies.size()


	for _unit: int in range(requested_quantity):
		create_zombie()


	var produced: int = zombies.size() - initial_zombie_count


	if produced == requested_quantity:
		batch_production_completed.emit(
			"zombie",
			produced,
			total_cost
		)


	update_bones_ui()
	return produced

func create_zombie() -> void:

	if run_finished:
		return


	if flesh < zombie_cost:

		print(
			"FLESH INSUFICIENTE!"
		)

		return


	var free_slot: int = (
		get_free_undead_slot()
	)


	if free_slot == -1:

		print(
			"LIMITE DE UNDEAD ATINGIDO!"
		)

		return


	var zombie_node: Node = (
		skeleton_scene.instantiate()
	)


	var new_zombie: Node2D = (
		zombie_node as Node2D
	)


	if new_zombie == null:

		push_error(
			"Placeholder de Zombie precisa de Node2D."
		)

		zombie_node.queue_free()

		return


	flesh -= zombie_cost


	add_child(
		new_zombie
	)


	ensure_unit_visual(
		new_zombie,
		ZOMBIE_COLOR,
		"zombie"
	)


	register_zombie(
		new_zombie,
		free_slot
	)


	total_zombies_created += 1


	update_bones_ui()
	update_debug_ui()


	print(
		"NOVO ZOMBIE CRIADO!"
	)

	print(
		"HP: ",
		zombie_max_hp,
		" | DMG: ",
		zombie_damage,
		" | COST: ",
		zombie_cost,
		" FLESH"
	)


func register_zombie(
	new_zombie: Node2D,
	slot: int
) -> void:

	zombies.append(
		new_zombie
	)


	zombie_hps[
		new_zombie
	] = zombie_max_hp


	zombie_attack_timers[
		new_zombie
	] = 0.0


	zombie_slots[
		new_zombie
	] = slot


	occupied_undead_slots[
		slot
	] = true


	new_zombie.position = (
		get_spawn_position(
			slot
		)
	)


	ensure_unit_health_bar(
		new_zombie,
		zombie_max_hp,
		zombie_max_hp,
		UI_GREEN,
		UNIT_SIZE
	)


	print(
		"ZOMBIE REGISTRADO! | SLOT: ",
		slot
	)


func zombie_attack_enemy(
	attacking_zombie: Node2D
) -> void:

	var target_enemy: Node2D = get_closest_enemy_to_unit(
		attacking_zombie
	)


	if target_enemy == null:
		return


	var remaining_hp: int = apply_damage_to_enemy(
		target_enemy,
		zombie_damage
	)


	if (
		zombie_recovery_per_attack > 0
		and zombie_hps.has(attacking_zombie)
	):

		var current_hp: int = int(
			zombie_hps[attacking_zombie]
		)


		var recovered_hp: int = mini(
			current_hp + zombie_recovery_per_attack,
			zombie_max_hp
		)
		zombie_hps[attacking_zombie] = recovered_hp
		update_unit_health_bar(
			attacking_zombie,
			recovered_hp,
			zombie_max_hp
		)


	zombie_attack_timers[
		attacking_zombie
	] = zombie_attack_cooldown


	print(
		"ZOMBIE ATACOU! | Enemy HP: ",
		remaining_hp,
		" | Zombies vivos: ",
		zombies.size()
	)


	if remaining_hp <= 0:
		kill_enemy(target_enemy)


func kill_zombie(
	target: Node2D
) -> void:

	print(
		"ZOMBIE MORREU!"
	)


	total_zombies_lost += 1


	if zombie_slots.has(target):

		var freed_slot: int = int(
			zombie_slots[target]
		)


		occupied_undead_slots.erase(
			freed_slot
		)


		zombie_slots.erase(
			target
		)


	zombie_hps.erase(
		target
	)


	zombie_attack_timers.erase(
		target
	)


	zombies.erase(
		target
	)


	target.queue_free()


	update_bones_ui()
	update_debug_ui()


# =========================================================
# VISUAL TEMPORÁRIO
# =========================================================

const SKELETON_COLOR: Color = Color.WHITE
const ZOMBIE_COLOR: Color = Color(0.35, 0.65, 0.25, 1.0)
const ENEMY_COLOR: Color = Color.RED
const ELITE_ENEMY_COLOR: Color = Color(0.55, 0.05, 0.15, 1.0)

const UNIT_SIZE: float = 70.0
const UNIT_SPRITE_HEIGHT: float = 96.0


# =========================================================
# MOVIMENTO
# =========================================================

var skeleton_speed: float = 180.0
var zombie_speed: float = 120.0
var enemy_speed: float = 100.0


# =========================================================
# VIDA
# =========================================================

var skeleton_max_hp: int = 100
var zombie_max_hp: int = 220

var enemy_max_hp: int = 100
var enemy_hp: int = 100


# =========================================================
# DANO
# =========================================================

var skeleton_damage: int = 10
var zombie_damage: int = 6
var enemy_damage: int = 8


# =========================================================
# COMBATE
# =========================================================

var skeleton_attack_cooldown: float = 0.7
var zombie_attack_cooldown: float = 1.1
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
var flesh: int = 0
var blood: int = 0
var souls: int = 0

var bones_per_corpse: int = 8
var flesh_per_corpse: int = 2

const PROCESSING_BALANCED: String = PROCESSING_DIRECTIVE_POLICY.BALANCED
const PROCESSING_BONE_FOCUS: String = PROCESSING_DIRECTIVE_POLICY.BONE_FOCUS
const PROCESSING_FLESH_FOCUS: String = PROCESSING_DIRECTIVE_POLICY.FLESH_FOCUS

var processing_directive: String = PROCESSING_BALANCED
var processing_directive_locked: bool = true
var corpses_processed_by_directive: Dictionary = {
	PROCESSING_BALANCED: 0,
	PROCESSING_BONE_FOCUS: 0,
	PROCESSING_FLESH_FOCUS: 0
}

var skeleton_cost: int = 5
var zombie_cost: int = 6


# =========================================================
# ENEMY
# =========================================================

var enemy: Node2D = null
var enemies: Array[Node2D] = []
var enemy_hps: Dictionary = {}
var enemy_max_hps: Dictionary = {}
var enemy_damages: Dictionary = {}
var enemy_speeds: Dictionary = {}
var enemy_attack_cooldowns: Dictionary = {}
var enemy_attack_ranges: Dictionary = {}
var enemy_attack_timers: Dictionary = {}
var enemy_lane_offsets: Dictionary = {}
var enemy_types: Dictionary = {}

const RIGHT_HUD_COMBAT_SAFE_X: float = 1450.0
const ENEMY_SPAWN_POSITION: Vector2 = Vector2(
	RIGHT_HUD_COMBAT_SAFE_X,
	555.0
)

# O combate acontece em uma faixa controlada da arena.
# Isso impede Enemy/Boss e formação de "arrastarem" uns aos
# outros infinitamente para fora da tela.
const ENEMY_LANE_Y: float = 555.0
const ENEMY_MIN_X: float = 650.0
const ENEMY_MAX_X: float = RIGHT_HUD_COMBAT_SAFE_X

const SKELETON_COMBAT_MIN_X: float = 80.0
const SKELETON_COMBAT_MAX_X: float = 1500.0
const SKELETON_COMBAT_MIN_Y: float = 300.0
const SKELETON_COMBAT_MAX_Y: float = 810.0

# Dentro da mesma Wave o próximo Enemy aparece rápido.
var enemy_spawn_delay: float = 0.5


# =========================================================
# DEBUG INPUT
# =========================================================

func _unhandled_input(
	event: InputEvent
) -> void:

	if event is InputEventKey:

		var key_event: InputEventKey = (
			event as InputEventKey
		)


		if (
			key_event.pressed
			and not key_event.echo
			and key_event.keycode == KEY_F3
		):

			if debug_label != null:

				debug_label.visible = (
					not debug_label.visible
				)


# =========================================================
# WAVES
# =========================================================

var current_wave: int = 1

var enemies_total_this_wave: int = 0
var enemies_defeated_this_wave: int = 0
var enemies_spawned_this_wave: int = 0
var enemy_refill_scheduled: bool = false

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
const BOSS_SPRITE_HEIGHT: float = 168.0

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
var run_end_build_label: Label = null
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
const UPGRADE_ROTTEN_BULK: String = "rotten_bulk"
const UPGRADE_GRAVE_HUNGER: String = "grave_hunger"
const UPGRADE_DEAD_WEIGHT: String = "dead_weight"
const UPGRADE_CARRION_RECOVERY: String = "carrion_recovery"

const MIN_SKELETON_ATTACK_COOLDOWN: float = 0.20

const BONE_HARVEST_CHANCE_PER_STACK: float = 0.20
const BONE_HARVEST_MAX_CHANCE: float = 1.0
const BONE_HARVEST_BONUS: int = 5

const REASSEMBLY_CHANCE_PER_STACK: float = 0.15
const REASSEMBLY_MAX_CHANCE: float = 0.75
const REASSEMBLY_HP_FRACTION: float = 0.50

const FINAL_SERVICE_DAMAGE_PER_STACK: int = 20
const ROTTEN_BULK_HP_PER_STACK: int = 40
const DEAD_WEIGHT_HP_PER_STACK: int = 70
const DEAD_WEIGHT_SPEED_MULTIPLIER: float = 0.90
const CARRION_RECOVERY_PER_STACK: int = 4

var bone_harvest_chance: float = 0.0
var reassembly_chance: float = 0.0
var final_service_damage: int = 0
var zombie_recovery_per_attack: int = 0

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
const SYNERGY_MEAT_SHIELD_PROTOCOL: String = "meat_shield_protocol"

const ASSEMBLY_LINE_CHANCE: float = 0.25
const OVERCLOCK_DOUBLE_STRIKE_CHANCE: float = 0.20
const SECOND_SHIFT_DAMAGE_MULTIPLIER: float = 0.50
const MEAT_SHIELD_TIMER_REDUCTION: float = 0.12

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

var total_zombies_created: int = 0
var total_zombies_lost: int = 0
var total_bones_earned: int = 0
var total_flesh_earned: int = 0


# =========================================================
# SKELETONS
# =========================================================

var skeletons: Array[Node2D] = []
var zombies: Array[Node2D] = []
var corpses: Array[Button] = []
var corpse_processing_queue: Array[Dictionary] = []

const CORPSE_PROCESSOR_BASE_CAPACITY: int = 5
const CORPSE_PROCESSOR_BASE_SECONDS: float = 0.65

var corpse_processor_capacity: int = CORPSE_PROCESSOR_BASE_CAPACITY
var corpse_processor_seconds_per_corpse: float = CORPSE_PROCESSOR_BASE_SECONDS
var corpse_processor_timer: float = 0.0

const FACTORY_AUTO_COLLECTION_COST: int = 2
const FACTORY_QUEUE_UPGRADE_BASE_COST: int = 1
const FACTORY_SPEED_UPGRADE_BASE_COST: int = 1
const FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL: int = 3
const FACTORY_AUTO_COLLECTION_SCAN_INTERVAL: float = 0.25
const FACTORY_QUEUE_CAPACITY_PER_LEVEL: int = 2
const FACTORY_PROCESSING_SECONDS_REDUCTION: float = 0.10

var factory_points: int = 0
var factory_queue_upgrade_level: int = 0
var factory_speed_upgrade_level: int = 0
var automatic_corpse_collection_unlocked: bool = false
var automatic_corpse_collection_enabled: bool = false
var automatic_corpse_collection_timer: float = 0.0

var army_doctrine_configured: bool = false
var doctrine_target_skeletons: int = 0
var doctrine_target_zombies: int = 0
var doctrine_bones_reserve: int = 0
var doctrine_flesh_reserve: int = 0
var doctrine_priority: String = ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED

var skeleton_hps: Dictionary = {}
var skeleton_attack_timers: Dictionary = {}

var zombie_hps: Dictionary = {}
var zombie_attack_timers: Dictionary = {}

# Unit -> slot
var skeleton_slots: Dictionary = {}
var zombie_slots: Dictionary = {}

# Slot -> ocupado
var occupied_undead_slots: Dictionary = {}


# =========================================================
# FORMAÇÃO DE SPAWN
# =========================================================

const FORMATION_COLUMNS: int = 6
const FORMATION_ROWS: int = 6

const MAX_UNDEAD: int = (
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
var brand_label: Label = null
var metrics_label: Label = null
var factory_title_label: Label = null
var processing_label: Label = null
var resources_panel: Panel = null
var processing_panel: Panel = null
var processing_directive_buttons: Dictionary = {}
var processing_directive_button_group: ButtonGroup = null
var resources_panel_tween: Tween = null
var factory_nav_button: Button = null
var factory_panel: ColorRect = null
var factory_points_label: Label = null
var factory_auto_collection_button: Button = null
var factory_queue_upgrade_button: Button = null
var factory_speed_upgrade_button: Button = null
var doctrine_nav_button: Button = null
var doctrine_panel: ColorRect = null
var doctrine_subtitle_label: Label = null
var doctrine_status_label: Label = null
var doctrine_validation_label: Label = null
var doctrine_target_skeletons_input: SpinBox = null
var doctrine_target_zombies_input: SpinBox = null
var doctrine_bones_reserve_input: SpinBox = null
var doctrine_flesh_reserve_input: SpinBox = null
var doctrine_priority_input: OptionButton = null

const RESOURCE_FEEDBACK_TARGET: Vector2 = Vector2(185.0, 820.0)

const UI_GREEN: Color = Color(0.38, 0.82, 0.25, 1.0)
const UI_GREEN_DIM: Color = Color(0.16, 0.36, 0.12, 1.0)
const UI_BONE: Color = Color(0.88, 0.84, 0.69, 1.0)
const UI_FLESH: Color = Color(0.70, 0.34, 0.28, 1.0)
const UI_TEXT: Color = Color(0.86, 0.86, 0.78, 1.0)
const UI_PANEL: Color = Color(0.025, 0.032, 0.031, 0.96)
const UI_PANEL_LIGHT: Color = Color(0.075, 0.085, 0.078, 0.98)
const UI_METAL_BORDER: Color = Color(0.29, 0.28, 0.23, 1.0)


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	create_zombie_ui()
	create_visual_shell()
	configure_primary_hud_layout()
	create_debug_hud()
	create_wave_hud()
	create_upgrade_ui()
	create_synergy_hud()
	create_run_end_ui()
	create_factory_panel_ui()
	create_army_doctrine_ui()


	# -----------------------------------------------------
	# SKELETON INICIAL
	# -----------------------------------------------------

	ensure_unit_visual(
		initial_skeleton,
		SKELETON_COLOR,
		"skeleton"
	)

	register_skeleton(
		initial_skeleton,
		0
	)


	# -----------------------------------------------------
	# BOTÃO
	# -----------------------------------------------------

	create_skeleton_button.pressed.connect(
		create_skeleton_batch_from_ui
	)


	create_zombie_button.pressed.connect(
		create_zombie_batch_from_ui
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


	update_corpse_processor(delta)
	update_automatic_corpse_collection(delta)


	check_defeat_condition()


	if run_finished:
		return


	cleanup_invalid_enemies()
	refresh_primary_enemy()


	if enemies.is_empty():
		return


	if get_total_undead_count() <= 0:
		return


	# =====================================================
	# COOLDOWNS
	# =====================================================

	if boss_active:

		boss_special_attack_timer = maxf(
			boss_special_attack_timer - delta,
			0.0
		)


		if (
			boss_special_attack_timer <= 0.0
			and get_total_undead_count() > 0
		):

			boss_special_attack()

			boss_special_attack_timer = (
				BOSS_SPECIAL_ATTACK_INTERVAL
			)


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var skeleton_timer: float = float(
			skeleton_attack_timers.get(
				current_skeleton,
				0.0
			)
		)


		skeleton_timer = maxf(
			skeleton_timer - delta,
			0.0
		)


		skeleton_attack_timers[
			current_skeleton
		] = skeleton_timer


	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		var zombie_timer: float = float(
			zombie_attack_timers.get(
				current_zombie,
				0.0
			)
		)


		zombie_timer = maxf(
			zombie_timer - delta,
			0.0
		)


		zombie_attack_timers[
			current_zombie
		] = zombie_timer


	# =====================================================
	# GRUPO DE ENEMIES PERSEGUE A FORMAÇÃO
	# =====================================================

	for current_enemy: Node2D in enemies.duplicate():

		if not is_instance_valid(current_enemy):
			continue


		var closest_undead: Node2D = (
			get_closest_undead_to_enemy(current_enemy)
		)


		if closest_undead == null:
			continue


		var current_attack_timer: float = float(
			enemy_attack_timers.get(current_enemy, 0.0)
		)
		current_attack_timer = maxf(
			current_attack_timer - delta,
			0.0
		)
		enemy_attack_timers[current_enemy] = current_attack_timer


		var lane_offset: float = float(
			enemy_lane_offsets.get(current_enemy, 0.0)
		)
		current_enemy.position.y = ENEMY_LANE_Y + lane_offset
		var current_attack_range: float = float(
			enemy_attack_ranges.get(current_enemy, enemy_attack_range)
		)
		var current_speed: float = float(
			enemy_speeds.get(current_enemy, enemy_speed)
		)


		var distance_to_undead: float = absf(
			current_enemy.position.x
			- closest_undead.position.x
		)


		if distance_to_undead > current_attack_range:

			var next_enemy_x: float = move_toward(
				current_enemy.position.x,
				closest_undead.position.x,
				current_speed * delta
			)
			current_enemy.position.x = clampf(
				next_enemy_x,
				ENEMY_MIN_X,
				ENEMY_MAX_X
			)

		elif current_attack_timer <= 0.0:

			damage_undead(
				closest_undead,
				int(enemy_damages.get(current_enemy, enemy_damage)),
				str(enemy_types.get(current_enemy, "ENEMY")).to_upper()
			)
			enemy_attack_timers[current_enemy] = (
				float(
					enemy_attack_cooldowns.get(
						current_enemy,
						enemy_attack_cooldown
					)
				)
			)


	if get_total_undead_count() <= 0:
		return


	# =====================================================
	# SKELETON COMBAT
	# =====================================================

	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		if not skeleton_slots.has(
			current_skeleton
		):
			continue


		var skeleton_slot: int = int(
			skeleton_slots[
				current_skeleton
			]
		)


		var skeleton_target: Vector2 = (
			get_combat_target_position(
				skeleton_slot
			)
		)


		var skeleton_distance: float = (
			current_skeleton.position.distance_to(
				skeleton_target
			)
		)


		if skeleton_distance > combat_position_tolerance:

			current_skeleton.position = (
				current_skeleton.position.move_toward(
					skeleton_target,
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


	# =====================================================
	# ZOMBIE COMBAT
	# =====================================================

	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		if not zombie_slots.has(
			current_zombie
		):
			continue


		var zombie_slot: int = int(
			zombie_slots[
				current_zombie
			]
		)


		var zombie_target: Vector2 = (
			get_combat_target_position(
				zombie_slot
			)
		)


		var zombie_distance: float = (
			current_zombie.position.distance_to(
				zombie_target
			)
		)


		if zombie_distance > combat_position_tolerance:

			current_zombie.position = (
				current_zombie.position.move_toward(
					zombie_target,
					zombie_speed * delta
				)
			)

		else:

			var zombie_timer: float = float(
				zombie_attack_timers.get(
					current_zombie,
					0.0
				)
			)


			if zombie_timer <= 0.0:

				zombie_attack_enemy(
					current_zombie
				)


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
	enemies_spawned_this_wave = 0
	enemy_refill_scheduled = false
	enemies.clear()
	enemy_hps.clear()
	enemy_max_hps.clear()
	enemy_damages.clear()
	enemy_speeds.clear()
	enemy_attack_cooldowns.clear()
	enemy_attack_ranges.clear()
	enemy_attack_timers.clear()
	enemy_lane_offsets.clear()
	enemy_types.clear()

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
	set_processing_directive_locked(true)


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
		"Base Enemy HP: ",
		enemy_max_hp,
		" | Base Damage: ",
		enemy_damage
	)

	print("==============================")


	if is_instance_valid(existing_enemy):

		register_enemy(existing_enemy)

	fill_enemy_group()


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


func get_max_simultaneous_enemies() -> int:

	return int(
		ENEMY_WAVE_POLICY.get_max_simultaneous_enemies(
			current_wave,
			BOSS_WAVE
		)
	)


func cleanup_invalid_enemies() -> void:

	var valid_enemies: Array[Node2D] = []


	for current_enemy: Node2D in enemies:

		if is_instance_valid(current_enemy):
			valid_enemies.append(current_enemy)
			continue


		enemy_hps.erase(current_enemy)
		enemy_max_hps.erase(current_enemy)
		enemy_damages.erase(current_enemy)
		enemy_speeds.erase(current_enemy)
		enemy_attack_cooldowns.erase(current_enemy)
		enemy_attack_ranges.erase(current_enemy)
		enemy_attack_timers.erase(current_enemy)
		enemy_lane_offsets.erase(current_enemy)
		enemy_types.erase(current_enemy)


	enemies = valid_enemies


func refresh_primary_enemy() -> void:

	if is_instance_valid(enemy) and enemies.has(enemy):
		enemy_hp = int(enemy_hps.get(enemy, enemy_hp))
		enemy_attack_timer = float(
			enemy_attack_timers.get(enemy, 0.0)
		)
		return


	enemy = null
	var closest_x: float = INF


	for current_enemy: Node2D in enemies:

		if not is_instance_valid(current_enemy):
			continue


		if current_enemy.position.x < closest_x:
			closest_x = current_enemy.position.x
			enemy = current_enemy


	if is_instance_valid(enemy):
		enemy_hp = int(enemy_hps.get(enemy, enemy_max_hp))
		enemy_attack_timer = float(
			enemy_attack_timers.get(enemy, 0.0)
		)


func get_closest_enemy_to_unit(
	unit: Node2D
) -> Node2D:

	if not is_instance_valid(unit):
		return null


	var closest_enemy: Node2D = null
	var closest_distance: float = INF


	for current_enemy: Node2D in enemies:

		if not is_instance_valid(current_enemy):
			continue


		var distance: float = unit.position.distance_squared_to(
			current_enemy.position
		)


		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = current_enemy


	return closest_enemy


func apply_damage_to_enemy(
	target_enemy: Node2D,
	damage_amount: int
) -> int:

	if not is_instance_valid(target_enemy):
		return 0


	if not enemy_hps.has(target_enemy):
		return 0


	var remaining_hp: int = int(enemy_hps[target_enemy])
	remaining_hp -= damage_amount
	enemy_hps[target_enemy] = remaining_hp


	if target_enemy == enemy:
		enemy_hp = remaining_hp


	update_unit_health_bar(
		target_enemy,
		remaining_hp,
		int(enemy_max_hps.get(target_enemy, enemy_max_hp))
	)


	return remaining_hp


func get_free_enemy_lane_offset() -> float:

	var lane_options: Array[float] = [
		0.0,
		-100.0,
		100.0,
		-200.0,
		200.0
	]


	for lane_offset: float in lane_options:

		if not enemy_lane_offsets.values().has(lane_offset):
			return lane_offset


	return 0.0


func register_enemy(new_enemy: Node2D) -> void:

	if not is_instance_valid(new_enemy):
		return


	if enemies.has(new_enemy):
		return


	var lane_offset: float = get_free_enemy_lane_offset()
	var archetype: Dictionary = ENEMY_ARCHETYPE_CATALOG.get_archetype(
		current_wave,
		enemies_spawned_this_wave,
		BOSS_WAVE
	)
	var archetype_id: String = str(archetype.get("id", "human_warrior"))
	var display_name: String = get_enemy_display_name(archetype_id)
	var maximum_hp: int = maxi(
		1,
		int(
			round(
				float(enemy_max_hp)
				* float(archetype.get("hp_multiplier", 1.0))
			)
		)
	)
	var attack_damage: int = maxi(
		1,
		int(
			round(
				float(enemy_damage)
				* float(archetype.get("damage_multiplier", 1.0))
			)
		)
	)
	var movement_speed: float = (
		enemy_speed
		* float(archetype.get("speed_multiplier", 1.0))
	)
	var visual_color: Color = archetype.get(
		"color",
		get_current_enemy_color()
	) as Color


	if is_elite_wave(current_wave):
		visual_color = visual_color.lerp(
			ELITE_ENEMY_COLOR,
			0.45
		)


	new_enemy.position = Vector2(
		ENEMY_SPAWN_POSITION.x,
		ENEMY_LANE_Y + lane_offset
	)
	ensure_unit_visual(
		new_enemy,
		visual_color,
		archetype_id
	)


	enemies.append(new_enemy)
	enemy_hps[new_enemy] = maximum_hp
	enemy_max_hps[new_enemy] = maximum_hp
	enemy_damages[new_enemy] = attack_damage
	enemy_speeds[new_enemy] = movement_speed
	enemy_attack_cooldowns[new_enemy] = float(
		archetype.get("cooldown", enemy_attack_cooldown)
	)
	enemy_attack_ranges[new_enemy] = float(
		archetype.get("attack_range", enemy_attack_range)
	)
	enemy_attack_timers[new_enemy] = 0.0
	enemy_lane_offsets[new_enemy] = lane_offset
	enemy_types[new_enemy] = archetype_id
	enemies_spawned_this_wave += 1


	if not is_instance_valid(enemy):
		enemy = new_enemy


	update_current_enemy_visual_size(new_enemy)
	ensure_enemy_health_bar(new_enemy)
	ensure_enemy_identity_label(
		new_enemy,
		display_name,
		visual_color
	)
	refresh_primary_enemy()


func fill_enemy_group() -> void:

	cleanup_invalid_enemies()


	while (
		wave_in_progress
		and enemies.size() < get_max_simultaneous_enemies()
		and enemies_spawned_this_wave < enemies_total_this_wave
	):

		spawn_enemy()


	update_wave_ui()
	update_debug_ui()


func schedule_enemy_refill() -> void:

	if enemy_refill_scheduled:
		return


	enemy_refill_scheduled = true


	await get_tree().create_timer(
		enemy_spawn_delay
	).timeout


	enemy_refill_scheduled = false


	if wave_in_progress:
		fill_enemy_group()


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

	var ordered_slots: Array[int] = []


	# Zombies entram primeiro na formação de combate.
	# Isso faz o tank ocupar naturalmente a linha de frente.
	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		if not zombie_slots.has(current_zombie):
			continue


		ordered_slots.append(
			int(zombie_slots[current_zombie])
		)


	# Skeletons ficam atrás dos Zombies.
	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		if not skeleton_slots.has(current_skeleton):
			continue


		ordered_slots.append(
			int(skeleton_slots[current_skeleton])
		)


	for index: int in range(
		ordered_slots.size()
	):

		if ordered_slots[index] == original_slot:
			return index


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


	occupied_undead_slots[
		slot
	] = true


	new_skeleton.position = (
		get_spawn_position(
			slot
		)
	)


	ensure_unit_health_bar(
		new_skeleton,
		skeleton_max_hp,
		skeleton_max_hp,
		UI_GREEN,
		UNIT_SIZE
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

func get_free_undead_slot() -> int:

	for slot: int in range(
		MAX_UNDEAD
	):

		if not occupied_undead_slots.has(
			slot
		):

			return slot


	return -1


# =========================================================
# UNDEAD ARMY HELPERS
# =========================================================

func get_total_undead_count() -> int:

	return (
		skeletons.size()
		+ zombies.size()
	)


func get_all_undead_units() -> Array[Node2D]:

	var units: Array[Node2D] = []


	for current_zombie: Node2D in zombies:

		if is_instance_valid(current_zombie):

			units.append(
				current_zombie
			)


	for current_skeleton: Node2D in skeletons:

		if is_instance_valid(current_skeleton):

			units.append(
				current_skeleton
			)


	return units


func get_closest_undead_to_enemy(
	source_enemy: Node2D = enemy
) -> Node2D:

	if not is_instance_valid(source_enemy):
		return null


	var closest_undead: Node2D = null
	var closest_horizontal_distance: float = INF
	var closest_vertical_distance: float = INF


	for current_undead: Node2D in get_all_undead_units():

		var horizontal_distance: float = absf(
			source_enemy.position.x
			- current_undead.position.x
		)


		var vertical_distance: float = absf(
			ENEMY_LANE_Y
			- current_undead.position.y
		)


		if horizontal_distance < closest_horizontal_distance:

			closest_horizontal_distance = horizontal_distance
			closest_vertical_distance = vertical_distance
			closest_undead = current_undead

		elif (
			is_equal_approx(
				horizontal_distance,
				closest_horizontal_distance
			)
			and vertical_distance < closest_vertical_distance
		):

			closest_vertical_distance = vertical_distance
			closest_undead = current_undead


	return closest_undead


func damage_undead(
	target: Node2D,
	damage_amount: int,
	source: String
) -> void:

	if skeleton_hps.has(target):

		var skeleton_hp: int = int(
			skeleton_hps[target]
		)


		skeleton_hp -= damage_amount


		skeleton_hps[target] = skeleton_hp
		update_unit_health_bar(
			target,
			skeleton_hp,
			skeleton_max_hp
		)


		print(
			source,
			" ATACOU! | Skeleton HP: ",
			skeleton_hp
		)


		if skeleton_hp <= 0:

			kill_skeleton(
				target
			)


		return


	if zombie_hps.has(target):

		var zombie_hp: int = int(
			zombie_hps[target]
		)


		zombie_hp -= damage_amount


		zombie_hps[target] = zombie_hp
		update_unit_health_bar(
			target,
			zombie_hp,
			zombie_max_hp
		)


		if has_synergy(SYNERGY_MEAT_SHIELD_PROTOCOL):
			accelerate_skeleton_line_from_zombie_hit()


		print(
			source,
			" ATACOU! | Zombie HP: ",
			zombie_hp
		)


		if zombie_hp <= 0:

			kill_zombie(
				target
			)


func accelerate_skeleton_line_from_zombie_hit() -> void:

	var accelerated_count: int = 0


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		if not skeleton_attack_timers.has(current_skeleton):
			continue


		var current_timer: float = float(
			skeleton_attack_timers[current_skeleton]
		)
		skeleton_attack_timers[current_skeleton] = maxf(
			current_timer - MEAT_SHIELD_TIMER_REDUCTION,
			0.0
		)
		accelerated_count += 1


	if accelerated_count > 0:
		print(
			"MEAT SHIELD PROTOCOL! ",
			accelerated_count,
			" Skeleton attack timers accelerated."
		)


# =========================================================
# SKELETON ATACA ENEMY
# =========================================================

func attack_enemy(
	attacking_skeleton: Node2D
) -> void:

	var target_enemy: Node2D = get_closest_enemy_to_unit(
		attacking_skeleton
	)


	if target_enemy == null:
		return


	var remaining_hp: int = apply_damage_to_enemy(
		target_enemy,
		skeleton_damage
	)


	var double_strike_triggered: bool = false


	if (
		has_synergy(
			SYNERGY_OVERCLOCKED_OSSUARY
		)
		and remaining_hp > 0
		and randf()
		< OVERCLOCK_DOUBLE_STRIKE_CHANCE
	):

		remaining_hp = apply_damage_to_enemy(
			target_enemy,
			skeleton_damage
		)

		double_strike_triggered = true


	skeleton_attack_timers[
		attacking_skeleton
	] = skeleton_attack_cooldown


	print(
		"SKELETON ATACOU! | Enemy HP: ",
		remaining_hp,
		" | Skeletons vivos: ",
		skeletons.size()
	)


	if double_strike_triggered:

		print(
			"OVERCLOCKED OSSUARY! DOUBLE STRIKE! +",
			skeleton_damage,
			" damage."
		)


	if remaining_hp <= 0:
		kill_enemy(target_enemy)


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
	update_unit_health_bar(
		target,
		current_hp,
		skeleton_max_hp
	)


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
		update_unit_health_bar(
			target,
			revived_hp,
			skeleton_max_hp
		)


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
			var second_shift_target: Node2D = enemy

			var second_shift_damage: int = int(
				round(
					float(final_service_damage)
					* SECOND_SHIFT_DAMAGE_MULTIPLIER
				)
			)


			if second_shift_damage < 1:

				second_shift_damage = 1


			var remaining_enemy_hp: int = apply_damage_to_enemy(
				second_shift_target,
				second_shift_damage
			)


			print(
				"SECOND SHIFT! O Skeleton reviveu e ainda causou ",
				second_shift_damage,
				" damage. | Enemy HP: ",
				remaining_enemy_hp
			)


			if remaining_enemy_hp <= 0:

				print(
					"SECOND SHIFT MATOU O ENEMY!"
				)

				kill_enemy(second_shift_target)


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
	var final_service_target: Node2D = null


	if (
		final_service_damage > 0
		and is_instance_valid(enemy)
	):
		final_service_target = enemy

		var remaining_enemy_hp: int = apply_damage_to_enemy(
			final_service_target,
			final_service_damage
		)


		print(
			"FINAL SERVICE! ",
			final_service_damage,
			" de dano. | Enemy HP: ",
			remaining_enemy_hp
		)


		if remaining_enemy_hp <= 0:
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


		occupied_undead_slots.erase(
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

		kill_enemy(final_service_target)


# =========================================================
# MATAR ENEMY / PROGREDIR WAVE
# =========================================================

func kill_enemy(target_enemy: Node2D = enemy) -> void:

	if not is_instance_valid(target_enemy):
		return


	if not enemies.has(target_enemy):
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


	var dead_enemy: Node2D = target_enemy


	var death_position: Vector2 = (
		dead_enemy.position
	)


	enemies.erase(dead_enemy)
	enemy_hps.erase(dead_enemy)
	enemy_max_hps.erase(dead_enemy)
	enemy_damages.erase(dead_enemy)
	enemy_speeds.erase(dead_enemy)
	enemy_attack_cooldowns.erase(dead_enemy)
	enemy_attack_ranges.erase(dead_enemy)
	enemy_attack_timers.erase(dead_enemy)
	enemy_lane_offsets.erase(dead_enemy)
	enemy_types.erase(dead_enemy)


	if dead_enemy == enemy:
		enemy = null


	if defeated_boss:
		boss_active = false


	spawn_corpse(
		death_position
	)
	update_metrics_ui()


	dead_enemy.queue_free()
	refresh_primary_enemy()


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
		set_processing_directive_locked(false)
		award_factory_points_for_wave(current_wave)


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
	# REPÕE O GRUPO ATIVO DA MESMA WAVE
	# =====================================================

	print(
		"REFORÇO INIMIGO EM ",
		enemy_spawn_delay,
		" SEGUNDOS..."
	)


	schedule_enemy_refill()


# =========================================================
# SPAWN ENEMY
# =========================================================

func spawn_enemy() -> void:

	if not wave_in_progress:
		return


	cleanup_invalid_enemies()


	if enemies.size() >= get_max_simultaneous_enemies():
		return


	if enemies_spawned_this_wave >= enemies_total_this_wave:
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


	register_enemy(new_enemy)


	print(
		"NOVO INIMIGO CRIADO!"
	)

	print(
		"Wave: ",
		current_wave,
		" | Type: ",
		str(enemy_types.get(new_enemy, "enemy")),
		" | Enemy HP: ",
		int(enemy_max_hps.get(new_enemy, enemy_max_hp)),
		" | Damage: ",
		int(enemy_damages.get(new_enemy, enemy_damage))
	)


	update_wave_ui()
	update_debug_ui()


# =========================================================
# BOSS
# =========================================================

func update_current_enemy_visual_size(
	target_enemy: Node2D = enemy
) -> void:

	if not is_instance_valid(target_enemy):
		return


	configure_unit_sprite(
		target_enemy,
		str(enemy_types.get(target_enemy, "human_warrior")),
		BOSS_SPRITE_HEIGHT if boss_active else UNIT_SPRITE_HEIGHT
	)


func boss_special_attack() -> void:

	if not boss_active:
		return


	if not is_instance_valid(enemy):
		return


	var valid_targets: Array[Node2D] = (
		get_all_undead_units()
	)


	if valid_targets.is_empty():
		return


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


	for index: int in range(
		target_count
	):

		var target: Node2D = (
			valid_targets[index]
		)


		if not is_instance_valid(target):
			continue


		damage_undead(
			target,
			BOSS_SPECIAL_ATTACK_DAMAGE,
			"BOSS AOE"
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
	corpse.text = tr("CORPSE_LABEL")


	corpse.position = (
		spawn_position
	)


	corpse.pressed.connect(

		func() -> void:

			enqueue_corpse_for_processing(
				corpse
			)
	)


	print(
		"CADÁVER CRIADO!"
	)


# =========================================================
# PROCESSAR CORPSE
# =========================================================

func enqueue_corpse_for_processing(corpse: Button) -> bool:

	if run_finished or not is_instance_valid(corpse):
		return false


	if is_corpse_queued(corpse):
		return false


	if corpse_processing_queue.size() >= corpse_processor_capacity:
		return false


	corpse_processing_queue.append(
		{
			"corpse": corpse,
			"directive": processing_directive
		}
	)
	corpse.disabled = true
	corpse.text = tr("CORPSE_QUEUED")


	if corpse_processing_queue.size() == 1:
		corpse_processor_timer = corpse_processor_seconds_per_corpse


	update_metrics_ui()
	return true


func update_corpse_processor(delta: float) -> void:

	cleanup_invalid_processing_queue()


	if corpse_processing_queue.is_empty():
		corpse_processor_timer = 0.0
		return


	corpse_processor_timer = maxf(corpse_processor_timer - delta, 0.0)


	if corpse_processor_timer > 0.0:
		return


	var queue_entry: Dictionary = corpse_processing_queue.pop_front()
	var corpse: Button = queue_entry.get("corpse") as Button
	var queued_directive: String = str(
		queue_entry.get("directive", processing_directive)
	)


	if not corpse_processing_queue.is_empty():
		corpse_processor_timer = corpse_processor_seconds_per_corpse


	if is_instance_valid(corpse):
		process_corpse(corpse, queued_directive)
	else:
		update_metrics_ui()


func is_corpse_queued(corpse: Button) -> bool:

	for queue_entry: Dictionary in corpse_processing_queue:
		if queue_entry.get("corpse") == corpse:
			return true


	return false


func remove_corpse_from_processing_queue(corpse: Button) -> void:

	for index: int in range(corpse_processing_queue.size() - 1, -1, -1):
		if corpse_processing_queue[index].get("corpse") == corpse:
			corpse_processing_queue.remove_at(index)


func cleanup_invalid_processing_queue() -> void:

	for index: int in range(corpse_processing_queue.size() - 1, -1, -1):
		var queued_corpse: Button = (
			corpse_processing_queue[index].get("corpse") as Button
		)


		if not is_instance_valid(queued_corpse):
			corpse_processing_queue.remove_at(index)


func update_automatic_corpse_collection(delta: float) -> void:

	if not automatic_corpse_collection_enabled:
		return


	if not automatic_corpse_collection_unlocked:
		automatic_corpse_collection_enabled = false
		update_factory_panel_ui()
		return


	automatic_corpse_collection_timer = maxf(
		automatic_corpse_collection_timer - delta,
		0.0
	)


	if automatic_corpse_collection_timer > 0.0:
		return


	automatic_corpse_collection_timer = (
		FACTORY_AUTO_COLLECTION_SCAN_INTERVAL
	)


	for corpse: Button in corpses:
		if corpse_processing_queue.size() >= corpse_processor_capacity:
			break


		if is_instance_valid(corpse) and not is_corpse_queued(corpse):
			enqueue_corpse_for_processing(corpse)


func set_automatic_corpse_collection_enabled(is_enabled: bool) -> bool:

	if is_enabled and not automatic_corpse_collection_unlocked:
		return false


	automatic_corpse_collection_enabled = is_enabled
	automatic_corpse_collection_timer = 0.0
	update_factory_panel_ui()
	return true


func toggle_automatic_corpse_collection() -> void:

	if not automatic_corpse_collection_unlocked:
		purchase_automatic_corpse_collection()
		return


	set_automatic_corpse_collection_enabled(
		not automatic_corpse_collection_enabled
	)


func purchase_automatic_corpse_collection() -> bool:

	if automatic_corpse_collection_unlocked:
		return false


	if factory_points < FACTORY_AUTO_COLLECTION_COST:
		return false


	factory_points -= FACTORY_AUTO_COLLECTION_COST
	automatic_corpse_collection_unlocked = true
	update_factory_panel_ui()
	return true


func purchase_factory_queue_upgrade() -> bool:

	if factory_queue_upgrade_level >= FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL:
		return false


	var cost: int = FACTORY_QUEUE_UPGRADE_BASE_COST + factory_queue_upgrade_level


	if factory_points < cost:
		return false


	factory_points -= cost
	factory_queue_upgrade_level += 1
	corpse_processor_capacity = (
		CORPSE_PROCESSOR_BASE_CAPACITY
		+ factory_queue_upgrade_level * FACTORY_QUEUE_CAPACITY_PER_LEVEL
	)
	update_metrics_ui()
	update_factory_panel_ui()
	return true


func purchase_factory_speed_upgrade() -> bool:

	if factory_speed_upgrade_level >= FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL:
		return false


	var cost: int = FACTORY_SPEED_UPGRADE_BASE_COST + factory_speed_upgrade_level


	if factory_points < cost:
		return false


	factory_points -= cost
	factory_speed_upgrade_level += 1
	corpse_processor_seconds_per_corpse = maxf(
		CORPSE_PROCESSOR_BASE_SECONDS
		- factory_speed_upgrade_level * FACTORY_PROCESSING_SECONDS_REDUCTION,
		0.1
	)
	update_metrics_ui()
	update_factory_panel_ui()
	return true


func award_factory_points_for_wave(wave_number: int) -> int:

	var points_earned: int = 1


	if is_elite_wave(wave_number):
		points_earned += 1


	factory_points += points_earned
	update_factory_panel_ui()
	return points_earned


func apply_army_doctrine_configuration(
	target_skeletons: int,
	target_zombies: int,
	bones_reserve: int,
	flesh_reserve: int,
	priority: String
) -> bool:

	if not ARMY_DOCTRINE_POLICY.is_valid_configuration(
		target_skeletons,
		target_zombies,
		bones_reserve,
		flesh_reserve,
		priority,
		MAX_UNDEAD
	):
		return false


	doctrine_target_skeletons = target_skeletons
	doctrine_target_zombies = target_zombies
	doctrine_bones_reserve = bones_reserve
	doctrine_flesh_reserve = flesh_reserve
	doctrine_priority = priority
	army_doctrine_configured = (
		target_skeletons > 0 or target_zombies > 0
	)


	if doctrine_target_skeletons_input != null:
		doctrine_target_skeletons_input.value = float(target_skeletons)
		doctrine_target_zombies_input.value = float(target_zombies)
		doctrine_bones_reserve_input.value = float(bones_reserve)
		doctrine_flesh_reserve_input.value = float(flesh_reserve)


	army_doctrine_changed.emit(get_army_doctrine_configuration())
	update_army_doctrine_ui()
	return true


func get_army_doctrine_configuration() -> Dictionary:

	return {
		"configured": army_doctrine_configured,
		"target_skeletons": doctrine_target_skeletons,
		"target_zombies": doctrine_target_zombies,
		"bones_reserve": doctrine_bones_reserve,
		"flesh_reserve": doctrine_flesh_reserve,
		"priority": doctrine_priority
	}


func get_army_doctrine_deficits() -> Vector2i:

	return ARMY_DOCTRINE_POLICY.get_deficits(
		doctrine_target_skeletons,
		doctrine_target_zombies,
		skeletons.size(),
		zombies.size()
	)


func doctrine_can_build_skeleton() -> bool:

	return ARMY_DOCTRINE_POLICY.can_spend_above_reserve(
		bones,
		skeleton_cost,
		doctrine_bones_reserve
	)


func doctrine_can_build_zombie() -> bool:

	return ARMY_DOCTRINE_POLICY.can_spend_above_reserve(
		flesh,
		zombie_cost,
		doctrine_flesh_reserve
	)

func get_processing_yield(
	directive: String = processing_directive
) -> Vector2i:

	return PROCESSING_DIRECTIVE_POLICY.get_yield(
		directive,
		bones_per_corpse,
		flesh_per_corpse
	)


func get_processing_directive_name(
	directive: String = processing_directive
) -> String:

	match directive:
		PROCESSING_BALANCED:
			return tr("PROCESSING_BALANCED")
		PROCESSING_BONE_FOCUS:
			return tr("PROCESSING_BONE_FOCUS")
		PROCESSING_FLESH_FOCUS:
			return tr("PROCESSING_FLESH_FOCUS")
		_:
			return PROCESSING_DIRECTIVE_POLICY.get_display_name(
				directive
			)


func get_enemy_display_name(archetype_id: String) -> String:

	match archetype_id:
		"human_warrior":
			return tr("ENEMY_HUMAN_WARRIOR")
		"mage":
			return tr("ENEMY_MAGE")
		"elf":
			return tr("ENEMY_ELF_SKIRMISHER")
		"foreman":
			return tr("ENEMY_THE_FOREMAN")
		_:
			return archetype_id.replace("_", " ").to_upper()


func set_processing_directive(directive: String) -> void:

	if not PROCESSING_DIRECTIVE_POLICY.is_valid(directive):
		push_warning("Unknown processing directive: " + directive)
		return


	if processing_directive_locked:
		print("PROCESSING DIRECTIVE LOCKED FOR WAVE ", current_wave)
		update_processing_directive_buttons()
		return


	processing_directive = directive


	for directive_id: String in processing_directive_buttons:
		var directive_button: Button = processing_directive_buttons[
			directive_id
		] as Button


		if directive_button != null:
			directive_button.button_pressed = (
				directive_id == processing_directive
			)


	print(
		"PROCESSING DIRECTIVE: ",
		get_processing_directive_name()
	)
	update_metrics_ui()
	refresh_army_doctrine_status()


func set_processing_directive_locked(is_locked: bool) -> void:

	processing_directive_locked = is_locked
	update_metrics_ui()


func process_corpse(
	corpse: Button,
	directive: String = processing_directive
) -> void:

	if run_finished:
		return


	if not is_instance_valid(corpse):
		return


	remove_corpse_from_processing_queue(corpse)
	corpse.disabled = true
	var feedback_origin: Vector2 = (
		corpse.global_position
		+ corpse.size * 0.5
	)
	var directive_yield: Vector2i = get_processing_yield(directive)
	var bones_gained: int = directive_yield.x

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


	var flesh_gained: int = directive_yield.y


	bones += bones_gained
	flesh += flesh_gained

	total_bones_earned += bones_gained
	total_flesh_earned += flesh_gained

	total_corpses_processed += 1
	corpses_processed_by_directive[directive] = (
		int(
			corpses_processed_by_directive.get(
				directive,
				0
			)
		)
		+ 1
	)
	play_corpse_processing_feedback(
		feedback_origin,
		bones_gained,
		flesh_gained,
		directive
	)


	update_bones_ui()


	print(
		"CADÁVER PROCESSADO!"
	)
	print(
		"DIRECTIVE: ",
		get_processing_directive_name(directive)
	)

	print(
		"+",
		bones_gained,
		" BONES"
	)

	print(
		"+",
		flesh_gained,
		" FLESH"
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
	update_metrics_ui()


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


func play_corpse_processing_feedback(
	feedback_origin: Vector2,
	bones_gained: int,
	flesh_gained: int,
	directive: String = processing_directive
) -> void:

	var accent_color: Color = get_processing_accent_color(directive)
	var feedback: Node2D = (
		CORPSE_PROCESSING_FEEDBACK_SCRIPT.new()
		as Node2D
	)


	if feedback == null:
		push_warning("Could not create Corpse processing feedback.")
		return


	feedback.name = "CorpseProcessingFeedback"
	add_child(feedback)
	feedback.call(
		"play",
		feedback_origin,
		RESOURCE_FEEDBACK_TARGET,
		bones_gained,
		flesh_gained,
		accent_color
	)
	pulse_resources_panel(accent_color)
	corpse_processing_feedback_started.emit(
		directive,
		bones_gained,
		flesh_gained
	)


func get_processing_accent_color(
	directive: String = processing_directive
) -> Color:

	match directive:
		PROCESSING_BONE_FOCUS:
			return UI_BONE
		PROCESSING_FLESH_FOCUS:
			return UI_FLESH
		_:
			return UI_GREEN


func pulse_resources_panel(accent_color: Color) -> void:

	if resources_panel == null:
		return


	if (
		resources_panel_tween != null
		and resources_panel_tween.is_valid()
	):
		resources_panel_tween.kill()


	resources_panel.modulate = Color(
		1.0 + accent_color.r * 0.22,
		1.0 + accent_color.g * 0.22,
		1.0 + accent_color.b * 0.22,
		1.0
	)
	resources_panel_tween = create_tween()
	resources_panel_tween.set_trans(Tween.TRANS_QUAD)
	resources_panel_tween.set_ease(Tween.EASE_OUT)
	resources_panel_tween.tween_property(
		resources_panel,
		"modulate",
		Color.WHITE,
		0.32
	)


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
		get_free_undead_slot()
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
		SKELETON_COLOR,
		"skeleton"
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
	color: Color,
	visual_id: String
) -> void:

	unit.set_meta("visual_accent", color)
	configure_unit_sprite(
		unit,
		visual_id,
		BOSS_SPRITE_HEIGHT if visual_id == "foreman" else UNIT_SPRITE_HEIGHT
	)


func configure_unit_sprite(
	unit: Node2D,
	visual_id: String,
	target_height: float
) -> void:

	var texture: Texture2D = UNIT_SPRITE_CATALOG.get_texture(visual_id)


	if texture == null:
		push_warning("Missing unit sprite for: " + visual_id)
		return


	var sprite: Sprite2D = unit.get_node_or_null("UnitSprite") as Sprite2D


	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "UnitSprite"
		sprite.z_index = 10
		unit.add_child(sprite)


	sprite.texture = texture
	var texture_height: float = maxf(float(texture.get_height()), 1.0)
	var uniform_scale: float = target_height / texture_height
	sprite.scale = Vector2(uniform_scale, uniform_scale)


func ensure_unit_health_bar(
	unit: Node2D,
	maximum_health: int,
	current_health: int,
	fill_color: Color,
	visual_size: float
) -> void:

	if not is_instance_valid(unit):
		return


	var health_bar: Node2D = (
		unit.get_node_or_null("HealthBar")
		as Node2D
	)


	if health_bar == null:

		health_bar = (
			UNIT_HEALTH_BAR_SCRIPT.new()
			as Node2D
		)


		if health_bar == null:
			push_error("Não foi possível criar UnitHealthBar.")
			return


		health_bar.name = "HealthBar"
		health_bar.z_index = 30
		unit.add_child(health_bar)


	health_bar.call(
		"configure",
		maximum_health,
		current_health,
		visual_size + 8.0,
		-visual_size * 0.5 - 14.0,
		fill_color
	)


func update_unit_health_bar(
	unit: Node2D,
	current_health: int,
	maximum_health: int
) -> void:

	if not is_instance_valid(unit):
		return


	var health_bar: Node = unit.get_node_or_null(
		"HealthBar"
	)


	if health_bar == null:
		return


	health_bar.call(
		"set_health",
		current_health,
		maximum_health
	)


func ensure_enemy_health_bar(
	target_enemy: Node2D = enemy
) -> void:

	if not is_instance_valid(target_enemy):
		return


	var visual_size: float = UNIT_SIZE
	var visual_accent: Color = target_enemy.get_meta(
		"visual_accent",
		Color(0.88, 0.16, 0.10, 1.0)
	) as Color
	var fill_color: Color = visual_accent.lightened(0.18)


	if boss_active:
		visual_size = BOSS_SIZE
		fill_color = Color(0.68, 0.18, 0.82, 1.0)


	ensure_unit_health_bar(
		target_enemy,
		int(enemy_max_hps.get(target_enemy, enemy_max_hp)),
		int(enemy_hps.get(target_enemy, enemy_max_hp)),
		fill_color,
		visual_size
	)


func ensure_enemy_identity_label(
	target_enemy: Node2D,
	display_name: String,
	accent_color: Color
) -> void:

	if not is_instance_valid(target_enemy):
		return


	var identity_label: Label = target_enemy.get_node_or_null(
		"IdentityLabel"
	) as Label


	if identity_label == null:
		identity_label = Label.new()
		identity_label.name = "IdentityLabel"
		identity_label.size = Vector2(180.0, 24.0)
		identity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		identity_label.z_index = 25
		identity_label.add_theme_font_size_override("font_size", 12)
		identity_label.add_theme_constant_override("outline_size", 4)
		target_enemy.add_child(identity_label)


	var label_y: float = -82.0


	if boss_active:
		label_y = -126.0


	identity_label.position = Vector2(-90.0, label_y)
	identity_label.text = display_name
	identity_label.add_theme_color_override("font_color", accent_color.lightened(0.30))
	identity_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.04, 0.95))



# =========================================================
# UPGRADE SYSTEM
# =========================================================

func create_upgrade_ui() -> void:

	upgrade_panel = ColorRect.new()

	upgrade_panel.name = "UpgradePanel"

	upgrade_panel.position = Vector2(
		300.0,
		230.0
	)

	upgrade_panel.size = Vector2(
		1320.0,
		540.0
	)

	upgrade_panel.color = Color(
		0.018,
		0.024,
		0.022,
		0.985
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
	upgrade_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_title_label.add_theme_font_size_override("font_size", 26)
	upgrade_title_label.add_theme_color_override("font_color", UI_GREEN)


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
	button.add_theme_font_size_override("font_size", 18)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	apply_button_style(button, UI_GREEN)


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
		UPGRADE_FINAL_SERVICE,
		UPGRADE_ROTTEN_BULK,
		UPGRADE_GRAVE_HUNGER,
		UPGRADE_DEAD_WEIGHT,
		UPGRADE_CARRION_RECOVERY
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


	if factory_panel != null:
		factory_panel.visible = false


	if doctrine_panel != null:
		doctrine_panel.visible = false


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


		if is_zombie_upgrade(upgrade_id):
			apply_button_style(button, UI_FLESH)
		else:
			apply_button_style(button, UI_GREEN)


func is_zombie_upgrade(
	upgrade_id: String
) -> bool:

	return upgrade_id in [
		UPGRADE_ROTTEN_BULK,
		UPGRADE_GRAVE_HUNGER,
		UPGRADE_DEAD_WEIGHT,
		UPGRADE_CARRION_RECOVERY
	]


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
				update_unit_health_bar(
					current_skeleton,
					current_hp + 25,
					skeleton_max_hp
				)


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


		UPGRADE_ROTTEN_BULK:

			increase_zombie_max_hp(
				ROTTEN_BULK_HP_PER_STACK
			)


		UPGRADE_GRAVE_HUNGER:

			var hungry_damage: int = int(
				ceil(float(zombie_damage) * 1.20)
			)


			zombie_damage = maxi(
				hungry_damage,
				zombie_damage + 1
			)


		UPGRADE_DEAD_WEIGHT:

			increase_zombie_max_hp(
				DEAD_WEIGHT_HP_PER_STACK
			)


			zombie_speed *= DEAD_WEIGHT_SPEED_MULTIPLIER


		UPGRADE_CARRION_RECOVERY:

			zombie_recovery_per_attack += (
				CARRION_RECOVERY_PER_STACK
			)


		_:

			push_error(
				"Upgrade desconhecido: "
				+ upgrade_id
			)


	update_bones_ui()
	update_debug_ui()


func increase_zombie_max_hp(
	amount: int
) -> void:

	zombie_max_hp += amount


	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		if not zombie_hps.has(current_zombie):
			continue


		zombie_hps[current_zombie] = (
			int(zombie_hps[current_zombie])
			+ amount
		)
		update_unit_health_bar(
			current_zombie,
			int(zombie_hps[current_zombie]),
			zombie_max_hp
		)


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

		UPGRADE_ROTTEN_BULK:
			return "Rotten Bulk"

		UPGRADE_GRAVE_HUNGER:
			return "Grave Hunger"

		UPGRADE_DEAD_WEIGHT:
			return "Dead Weight"

		UPGRADE_CARRION_RECOVERY:
			return "Carrion Recovery"

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

		UPGRADE_ROTTEN_BULK:
			return (
				"Zombie Max HP +40"
				+ "\nExisting Zombies gain +40 HP"
			)

		UPGRADE_GRAVE_HUNGER:
			return "Zombie Damage +20%"

		UPGRADE_DEAD_WEIGHT:
			return (
				"Zombie Max HP +70"
				+ "\nMovement Speed -10%"
			)

		UPGRADE_CARRION_RECOVERY:
			return (
				"Zombies recover 4 HP"
				+ "\nafter every attack"
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

		UPGRADE_ROTTEN_BULK:
			return (
				"Zombie Max HP: "
				+ str(zombie_max_hp)
			)

		UPGRADE_GRAVE_HUNGER:
			return (
				"Zombie DMG: "
				+ str(zombie_damage)
			)

		UPGRADE_DEAD_WEIGHT:
			return (
				"HP "
				+ str(zombie_max_hp)
				+ " | Speed "
				+ str(int(round(zombie_speed)))
			)

		UPGRADE_CARRION_RECOVERY:
			return (
				"Recovery per Attack: "
				+ str(zombie_recovery_per_attack)
				+ " HP"
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


	if (
		get_upgrade_count(
			UPGRADE_ROTTEN_BULK
		) > 0
		and get_upgrade_count(
			UPGRADE_RAPID_ASSAULT
		) > 0
	):

		unlock_synergy(
			SYNERGY_MEAT_SHIELD_PROTOCOL
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
			return tr("SYNERGY_RECYCLING_PLANT")

		SYNERGY_SECOND_SHIFT:
			return tr("SYNERGY_SECOND_SHIFT")

		SYNERGY_BONE_ASSEMBLY_LINE:
			return tr("SYNERGY_BONE_ASSEMBLY_LINE")

		SYNERGY_OVERCLOCKED_OSSUARY:
			return tr("SYNERGY_OVERCLOCKED_OSSUARY")

		SYNERGY_MEAT_SHIELD_PROTOCOL:
			return tr("SYNERGY_MEAT_SHIELD_PROTOCOL")

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

		SYNERGY_MEAT_SHIELD_PROTOCOL:
			return (
				"Rotten Bulk + Rapid Assault"
				+ "\nZombie hits accelerate every Skeleton attack timer by 0.12s."
			)

		_:
			return ""


func create_synergy_hud() -> void:

	synergy_label = Label.new()

	synergy_label.name = "SynergyLabel"

	synergy_label.position = Vector2(
		1565.0,
		320.0
	)

	synergy_label.size = Vector2(
		305.0,
		125.0
	)

	synergy_label.z_index = 100
	synergy_label.add_theme_font_size_override("font_size", 16)
	synergy_label.add_theme_color_override("font_color", UI_TEXT)


	add_child(
		synergy_label
	)


	update_synergy_ui()


func update_synergy_ui() -> void:

	if synergy_label == null:
		return


	var text_value: String = tr("SYNERGIES_ACTIVE")


	if active_synergies.is_empty():

		text_value += "\n" + tr("COMMON_NONE")

	else:

		var synergy_order: Array[String] = [
			SYNERGY_RECYCLING_PLANT,
			SYNERGY_SECOND_SHIFT,
			SYNERGY_BONE_ASSEMBLY_LINE,
			SYNERGY_OVERCLOCKED_OSSUARY,
			SYNERGY_MEAT_SHIELD_PROTOCOL
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


	if wave_transition_in_progress:
		return


	if not wave_in_progress:
		return


	if get_total_undead_count() > 0:
		return


	cleanup_invalid_corpses()


	if not corpses.is_empty():
		return


	var can_build_skeleton: bool = (
		bones >= skeleton_cost
	)


	var can_build_zombie: bool = (
		flesh >= zombie_cost
	)


	if (
		can_build_skeleton
		or can_build_zombie
	):

		return


	print("")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("NO VIABLE UNDEAD PRODUCTION REMAINS")
	print(
		"Skeletons: 0 | Zombies: 0 | Corpses: 0"
	)
	print(
		"Bones: ",
		bones,
		" / ",
		skeleton_cost,
		" | Flesh: ",
		flesh,
		" / ",
		zombie_cost
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
		0.985
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
		410.0,
		70.0
	)

	run_end_title_label.size = Vector2(
		1100.0,
		100.0
	)

	run_end_title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	run_end_title_label.text = (
		"RUN COMPLETE"
	)
	run_end_title_label.add_theme_font_size_override(
		"font_size",
		30
	)
	run_end_title_label.add_theme_color_override(
		"font_color",
		UI_BONE
	)


	run_end_panel.add_child(
		run_end_title_label
	)


	run_end_summary_label = Label.new()

	run_end_summary_label.name = "RunEndSummary"

	run_end_summary_label.position = Vector2(
		330.0,
		205.0
	)

	run_end_summary_label.size = Vector2(
		650.0,
		560.0
	)

	run_end_summary_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_LEFT
	)

	run_end_summary_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_TOP
	)
	run_end_summary_label.add_theme_font_size_override(
		"font_size",
		17
	)
	run_end_summary_label.add_theme_color_override(
		"font_color",
		UI_TEXT
	)


	run_end_panel.add_child(
		run_end_summary_label
	)


	run_end_build_label = Label.new()
	run_end_build_label.name = "RunEndBuildSummary"
	run_end_build_label.position = Vector2(1030.0, 205.0)
	run_end_build_label.size = Vector2(560.0, 560.0)
	run_end_build_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_LEFT
	)
	run_end_build_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_TOP
	)
	run_end_build_label.add_theme_font_size_override(
		"font_size",
		17
	)
	run_end_build_label.add_theme_color_override(
		"font_color",
		UI_TEXT
	)
	run_end_panel.add_child(run_end_build_label)


	restart_run_button = Button.new()

	restart_run_button.name = "RestartRunButton"

	restart_run_button.position = Vector2(
		760.0,
		850.0
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

	if create_zombie_button != null:
		create_zombie_button.disabled = true


	for directive_button_value: Variant in processing_directive_buttons.values():
		var directive_button: Button = directive_button_value as Button


		if directive_button != null:
			directive_button.disabled = true


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


	if run_end_build_label == null:
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
		"RUN STATISTICS"
		+ "\n\nPROGRESS"
		+ "\nWave Reached: "
		+ str(current_wave)
		+ "\nEnemies Killed: "
		+ str(total_enemies_killed)
		+ "\nCorpses Processed: "
		+ str(total_corpses_processed)
		+ "\nCorpses Remaining: "
		+ str(corpses.size())
		+ "\n\nUNDEAD PRODUCTION"
		+ "\nSkeletons Built: "
		+ str(total_skeletons_created)
		+ "\nSkeletons Lost: "
		+ str(total_skeletons_lost)
		+ "\nSkeletons Revived: "
		+ str(total_skeletons_revived)
		+ "\nZombies Built: "
		+ str(total_zombies_created)
		+ "\nZombies Lost: "
		+ str(total_zombies_lost)
		+ "\n\nECONOMY"
		+ "\nBones Earned: "
		+ str(total_bones_earned)
		+ "\nFlesh Earned: "
		+ str(total_flesh_earned)
		+ "\nBones Remaining: "
		+ str(bones)
		+ "\nFlesh Remaining: "
		+ str(flesh)
		+ "\nBlood Remaining: "
		+ str(blood)
		+ "\nSouls Remaining: "
		+ str(souls)
	)


	run_end_build_label.text = (
		"BUILD SUMMARY"
		+ "\n\nArmy Remaining: "
		+ str(get_total_undead_count())
		+ "\nUpgrades Selected: "
		+ str(total_upgrades_selected)
		+ "\nSynergies Unlocked: "
		+ str(active_synergies.size())
		+ "\n\nPROCESSING ROUTES"
		+ "\nBalanced: "
		+ str(int(corpses_processed_by_directive[PROCESSING_BALANCED]))
		+ "\nBone Focus: "
		+ str(int(corpses_processed_by_directive[PROCESSING_BONE_FOCUS]))
		+ "\nFlesh Focus: "
		+ str(int(corpses_processed_by_directive[PROCESSING_FLESH_FOCUS]))
		+ "\n\n"
		+ get_run_synergy_summary()
		+ "\n\nOPERATION STATUS"
		+ "\n"
		+ get_run_result_message()
	)


	run_end_panel.visible = true


func get_run_result_message() -> String:

	if run_won:

		return (
			"Result: Production target achieved."
		)


	return (
		"Result: No Undead, no Corpses, "
		+ "and insufficient resources to rebuild."
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
		SYNERGY_OVERCLOCKED_OSSUARY,
		SYNERGY_MEAT_SHIELD_PROTOCOL
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
		675.0,
		38.0
	)

	wave_label.size = Vector2(
		570.0,
		110.0
	)

	wave_label.z_index = 100
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_label.add_theme_font_size_override("font_size", 19)
	wave_label.add_theme_color_override("font_color", UI_TEXT)


	add_child(
		wave_label
	)


func update_wave_ui() -> void:

	if wave_label == null:
		return


	if run_finished:

		if run_won:
			wave_label.text = (
				tr("RUN_COMPLETE")
				+ "\n" + tr("RUN_VICTORY")
			)

		else:
			wave_label.text = (
				tr("RUN_COMPLETE")
				+ "\n" + tr("RUN_DEFEAT")
			)

		return


	var wave_title: String = (
		tr("HUD_WAVE") + " "
		+ str(current_wave)
	)


	if is_boss_wave(current_wave):

		wave_title += (
			" - " + tr("WAVE_BOSS") + ": "
			+ get_enemy_display_name("foreman")
		)

	elif is_elite_wave(current_wave):

		wave_title += " - " + tr("WAVE_ELITE")


	if wave_transition_in_progress:

		wave_label.text = (
			wave_title
			+ " " + tr("WAVE_COMPLETE")
			+ "\n" + tr("WAVE_SELECT_UPGRADE")
		)

		return


	wave_label.text = (
		wave_title
		+ "\n" + tr("WAVE_ENEMIES_REMAINING") + ": "
		+ str(get_enemies_remaining())
		+ " / "
		+ str(enemies_total_this_wave)
		+ " | " + tr("WAVE_ACTIVE") + ": "
		+ str(enemies.size())
		+ " / "
		+ str(get_max_simultaneous_enemies())
		+ "\n" + tr("WAVE_PRIMARY") + ": "
		+ get_enemy_display_name(str(enemy_types.get(enemy, "human_warrior")))
		+ " | " + tr("STAT_HP") + ": "
		+ str(int(enemy_max_hps.get(enemy, enemy_max_hp)))
		+ " | " + tr("STAT_DAMAGE") + ": "
		+ str(int(enemy_damages.get(enemy, enemy_damage)))
	)


# =========================================================
# ZOMBIE UI
# =========================================================

func create_zombie_ui() -> void:

	create_zombie_button = Button.new()

	create_zombie_button.name = "CreateZombieButton"

	create_zombie_button.text = (
		"CREATE ZOMBIE"
	)


	add_child(
		create_zombie_button
	)


	production_quantity_selector = SpinBox.new()
	production_quantity_selector.name = "ProductionQuantitySelector"
	production_quantity_selector.min_value = 1.0
	production_quantity_selector.max_value = float(MAX_UNDEAD)
	production_quantity_selector.step = 1.0
	production_quantity_selector.value = 1.0
	production_quantity_selector.allow_greater = false
	production_quantity_selector.allow_lesser = false
	production_quantity_selector.update_on_text_changed = true
	production_quantity_selector.z_index = 110
	production_quantity_selector.add_theme_font_size_override("font_size", 16)
	production_quantity_selector.value_changed.connect(
		func(_value: float) -> void:
			update_bones_ui()
	)
	add_child(production_quantity_selector)


# =========================================================
# NECROWORKS VISUAL SHELL
# =========================================================

func create_visual_shell() -> void:

	create_hud_panel(
		"WavePanel",
		Rect2(650.0, 22.0, 620.0, 140.0)
	)

	create_hud_panel(
		"MetricsPanel",
		Rect2(1540.0, 18.0, 355.0, 280.0)
	)

	create_hud_panel(
		"SynergyPanel",
		Rect2(1540.0, 305.0, 355.0, 155.0)
	)

	resources_panel = create_hud_panel(
		"ResourcesPanel",
		Rect2(20.0, 842.0, 330.0, 215.0)
	)

	create_hud_panel(
		"ProductionPanel",
		Rect2(365.0, 842.0, 700.0, 215.0)
	)

	processing_panel = create_hud_panel(
		"ProcessingPanel",
		Rect2(1080.0, 842.0, 815.0, 215.0)
	)

	brand_label = Label.new()
	brand_label.name = "BrandLabel"
	brand_label.position = Vector2(28.0, 20.0)
	brand_label.size = Vector2(560.0, 60.0)
	brand_label.text = "NECROWORKS"
	brand_label.z_index = 100
	brand_label.add_theme_font_size_override("font_size", 38)
	brand_label.add_theme_color_override("font_color", UI_BONE)
	brand_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	brand_label.add_theme_constant_override("shadow_offset_x", 3)
	brand_label.add_theme_constant_override("shadow_offset_y", 3)
	add_child(brand_label)

	var tagline_label: Label = Label.new()
	tagline_label.name = "TaglineLabel"
	tagline_label.position = Vector2(31.0, 82.0)
	tagline_label.size = Vector2(560.0, 75.0)
	tagline_label.text = (
		"INDUSTRIAL REANIMATION SOLUTIONS"
		+ "\nWASTE NOTHING. RAISE EVERYTHING."
	)
	tagline_label.z_index = 100
	tagline_label.add_theme_font_size_override("font_size", 18)
	tagline_label.add_theme_color_override("font_color", UI_GREEN)
	add_child(tagline_label)

	metrics_label = Label.new()
	metrics_label.name = "MetricsLabel"
	metrics_label.position = Vector2(1565.0, 35.0)
	metrics_label.size = Vector2(305.0, 245.0)
	metrics_label.z_index = 100
	metrics_label.add_theme_font_size_override("font_size", 16)
	metrics_label.add_theme_color_override("font_color", UI_TEXT)
	add_child(metrics_label)

	factory_title_label = Label.new()
	factory_title_label.name = "FactoryTitleLabel"
	factory_title_label.position = Vector2(390.0, 855.0)
	factory_title_label.size = Vector2(650.0, 45.0)
	factory_title_label.text = tr("FACTORY_PRODUCTION_LINE")
	factory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	factory_title_label.z_index = 100
	factory_title_label.add_theme_font_size_override("font_size", 22)
	factory_title_label.add_theme_color_override("font_color", UI_GREEN)
	add_child(factory_title_label)

	processing_label = Label.new()
	processing_label.name = "ProcessingLabel"
	processing_label.position = Vector2(1110.0, 862.0)
	processing_label.size = Vector2(755.0, 118.0)
	processing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	processing_label.z_index = 100
	processing_label.add_theme_font_size_override("font_size", 18)
	processing_label.add_theme_color_override("font_color", UI_TEXT)
	add_child(processing_label)
	create_processing_directive_ui()

	update_metrics_ui()


func create_factory_panel_ui() -> void:

	factory_nav_button = Button.new()
	factory_nav_button.name = "FactoryNavButton"
	factory_nav_button.position = Vector2(20.0, 770.0)
	factory_nav_button.size = Vector2(180.0, 52.0)
	factory_nav_button.z_index = 160
	apply_button_style(factory_nav_button, UI_GREEN)
	factory_nav_button.pressed.connect(toggle_factory_panel)
	add_child(factory_nav_button)


	factory_panel = ColorRect.new()
	factory_panel.name = "FactoryPanel"
	factory_panel.position = Vector2(510.0, 190.0)
	factory_panel.size = Vector2(900.0, 600.0)
	factory_panel.color = Color(0.018, 0.024, 0.022, 0.992)
	factory_panel.z_index = 650
	factory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(factory_panel)


	var title_label: Label = Label.new()
	title_label.name = "FactoryPanelTitle"
	title_label.position = Vector2(40.0, 25.0)
	title_label.size = Vector2(820.0, 45.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", UI_GREEN)
	factory_panel.add_child(title_label)


	factory_points_label = Label.new()
	factory_points_label.name = "FactoryPointsLabel"
	factory_points_label.position = Vector2(40.0, 78.0)
	factory_points_label.size = Vector2(820.0, 38.0)
	factory_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	factory_points_label.add_theme_font_size_override("font_size", 18)
	factory_points_label.add_theme_color_override("font_color", UI_BONE)
	factory_panel.add_child(factory_points_label)


	var close_button: Button = Button.new()
	close_button.name = "FactoryCloseButton"
	close_button.position = Vector2(740.0, 525.0)
	close_button.size = Vector2(120.0, 48.0)
	apply_button_style(close_button, UI_FLESH)
	close_button.pressed.connect(toggle_factory_panel)
	factory_panel.add_child(close_button)


	factory_auto_collection_button = create_factory_upgrade_button(
		"FactoryAutoCollectionButton",
		Vector2(40.0, 140.0),
		UI_GREEN
	)
	factory_auto_collection_button.pressed.connect(
		toggle_automatic_corpse_collection
	)


	factory_queue_upgrade_button = create_factory_upgrade_button(
		"FactoryQueueUpgradeButton",
		Vector2(320.0, 140.0),
		UI_BONE
	)
	factory_queue_upgrade_button.pressed.connect(
		purchase_factory_queue_upgrade
	)


	factory_speed_upgrade_button = create_factory_upgrade_button(
		"FactorySpeedUpgradeButton",
		Vector2(600.0, 140.0),
		Color(0.35, 0.62, 0.82, 1.0)
	)
	factory_speed_upgrade_button.pressed.connect(
		purchase_factory_speed_upgrade
	)


	factory_panel.visible = false
	update_factory_panel_ui()


func create_factory_upgrade_button(
	button_name: String,
	button_position: Vector2,
	accent_color: Color
) -> Button:

	var button: Button = Button.new()
	button.name = button_name
	button.position = button_position
	button.size = Vector2(260.0, 330.0)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 17)
	apply_button_style(button, accent_color)
	factory_panel.add_child(button)
	return button


func toggle_factory_panel() -> void:

	if factory_panel == null:
		return


	if upgrade_panel != null and upgrade_panel.visible:
		factory_panel.visible = false
		return


	if doctrine_panel != null:
		doctrine_panel.visible = false


	factory_panel.visible = not factory_panel.visible
	update_factory_panel_ui()


func update_factory_panel_ui() -> void:

	if factory_nav_button == null or factory_panel == null:
		return


	factory_nav_button.text = tr("FACTORY_NAV")
	var title_label: Label = factory_panel.get_node_or_null(
		"FactoryPanelTitle"
	) as Label
	var close_button: Button = factory_panel.get_node_or_null(
		"FactoryCloseButton"
	) as Button


	if title_label != null:
		title_label.text = tr("FACTORY_PANEL_TITLE")


	if close_button != null:
		close_button.text = tr("FACTORY_CLOSE")


	factory_points_label.text = (
		tr("FACTORY_POINTS") + ": " + str(factory_points)
	)
	update_factory_auto_collection_button()
	update_factory_queue_upgrade_button()
	update_factory_speed_upgrade_button()


func update_factory_auto_collection_button() -> void:

	if factory_auto_collection_button == null:
		return


	if automatic_corpse_collection_unlocked:
		var state_key: String = (
			"FACTORY_AUTO_ENABLED"
			if automatic_corpse_collection_enabled
			else "FACTORY_AUTO_DISABLED"
		)
		factory_auto_collection_button.text = (
			tr("FACTORY_AUTO_COLLECTION")
			+ "\n\n" + tr(state_key)
			+ "\n\n" + tr("FACTORY_COST") + ": 0"
		)
		factory_auto_collection_button.disabled = false
		return


	factory_auto_collection_button.text = (
		tr("FACTORY_AUTO_COLLECTION")
		+ "\n\n" + tr("FACTORY_AUTO_LOCKED")
		+ "\n\n" + tr("FACTORY_COST") + ": "
		+ str(FACTORY_AUTO_COLLECTION_COST)
	)
	factory_auto_collection_button.disabled = (
		factory_points < FACTORY_AUTO_COLLECTION_COST
	)


func update_factory_queue_upgrade_button() -> void:

	if factory_queue_upgrade_button == null:
		return


	var at_max: bool = (
		factory_queue_upgrade_level >= FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL
	)
	var cost: int = FACTORY_QUEUE_UPGRADE_BASE_COST + factory_queue_upgrade_level
	factory_queue_upgrade_button.text = (
		tr("FACTORY_QUEUE_UPGRADE")
		+ "\n\n" + tr("FACTORY_LEVEL") + ": "
		+ str(factory_queue_upgrade_level)
		+ " / " + str(FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL)
		+ "\n" + tr("FACTORY_CAPACITY") + ": "
		+ str(corpse_processor_capacity)
		+ "\n\n"
		+ (tr("FACTORY_MAX_LEVEL") if at_max else tr("FACTORY_COST") + ": " + str(cost))
	)
	factory_queue_upgrade_button.disabled = at_max or factory_points < cost


func update_factory_speed_upgrade_button() -> void:

	if factory_speed_upgrade_button == null:
		return


	var at_max: bool = (
		factory_speed_upgrade_level >= FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL
	)
	var cost: int = FACTORY_SPEED_UPGRADE_BASE_COST + factory_speed_upgrade_level
	factory_speed_upgrade_button.text = (
		tr("FACTORY_SPEED_UPGRADE")
		+ "\n\n" + tr("FACTORY_LEVEL") + ": "
		+ str(factory_speed_upgrade_level)
		+ " / " + str(FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL)
		+ "\n" + tr("FACTORY_CYCLE") + ": "
		+ str(corpse_processor_seconds_per_corpse) + "s"
		+ "\n\n"
		+ (tr("FACTORY_MAX_LEVEL") if at_max else tr("FACTORY_COST") + ": " + str(cost))
	)
	factory_speed_upgrade_button.disabled = at_max or factory_points < cost


func create_army_doctrine_ui() -> void:

	doctrine_nav_button = Button.new()
	doctrine_nav_button.name = "DoctrineNavButton"
	doctrine_nav_button.position = Vector2(210.0, 770.0)
	doctrine_nav_button.size = Vector2(180.0, 52.0)
	doctrine_nav_button.z_index = 160
	apply_button_style(doctrine_nav_button, UI_BONE)
	doctrine_nav_button.pressed.connect(toggle_army_doctrine_panel)
	add_child(doctrine_nav_button)


	doctrine_panel = ColorRect.new()
	doctrine_panel.name = "ArmyDoctrinePanel"
	doctrine_panel.position = Vector2(510.0, 190.0)
	doctrine_panel.size = Vector2(900.0, 600.0)
	doctrine_panel.color = Color(0.018, 0.024, 0.022, 0.992)
	doctrine_panel.z_index = 650
	doctrine_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(doctrine_panel)


	var title_label: Label = Label.new()
	title_label.name = "DoctrineTitle"
	title_label.position = Vector2(40.0, 24.0)
	title_label.size = Vector2(820.0, 45.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", UI_BONE)
	doctrine_panel.add_child(title_label)


	doctrine_subtitle_label = Label.new()
	doctrine_subtitle_label.name = "DoctrineSubtitle"
	doctrine_subtitle_label.position = Vector2(40.0, 72.0)
	doctrine_subtitle_label.size = Vector2(820.0, 35.0)
	doctrine_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	doctrine_subtitle_label.add_theme_font_size_override("font_size", 15)
	doctrine_subtitle_label.add_theme_color_override("font_color", UI_FLESH)
	doctrine_panel.add_child(doctrine_subtitle_label)


	doctrine_target_skeletons_input = create_doctrine_spinbox(
		"DoctrineTargetSkeletons",
		Vector2(65.0, 135.0),
		float(MAX_UNDEAD)
	)
	doctrine_target_zombies_input = create_doctrine_spinbox(
		"DoctrineTargetZombies",
		Vector2(465.0, 135.0),
		float(MAX_UNDEAD)
	)
	doctrine_bones_reserve_input = create_doctrine_spinbox(
		"DoctrineBonesReserve",
		Vector2(65.0, 215.0),
		99999.0
	)
	doctrine_flesh_reserve_input = create_doctrine_spinbox(
		"DoctrineFleshReserve",
		Vector2(465.0, 215.0),
		99999.0
	)


	doctrine_priority_input = OptionButton.new()
	doctrine_priority_input.name = "DoctrinePriority"
	doctrine_priority_input.position = Vector2(245.0, 305.0)
	doctrine_priority_input.size = Vector2(410.0, 48.0)
	doctrine_priority_input.add_theme_font_size_override("font_size", 16)
	apply_button_style(doctrine_priority_input, UI_GREEN)
	doctrine_panel.add_child(doctrine_priority_input)


	doctrine_status_label = Label.new()
	doctrine_status_label.name = "DoctrineStatus"
	doctrine_status_label.position = Vector2(80.0, 375.0)
	doctrine_status_label.size = Vector2(740.0, 100.0)
	doctrine_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	doctrine_status_label.add_theme_font_size_override("font_size", 18)
	doctrine_status_label.add_theme_color_override("font_color", UI_TEXT)
	doctrine_panel.add_child(doctrine_status_label)


	doctrine_validation_label = Label.new()
	doctrine_validation_label.name = "DoctrineValidation"
	doctrine_validation_label.position = Vector2(60.0, 480.0)
	doctrine_validation_label.size = Vector2(780.0, 35.0)
	doctrine_validation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	doctrine_validation_label.add_theme_font_size_override("font_size", 15)
	doctrine_validation_label.add_theme_color_override("font_color", UI_FLESH)
	doctrine_panel.add_child(doctrine_validation_label)


	var apply_button: Button = Button.new()
	apply_button.name = "DoctrineApplyButton"
	apply_button.position = Vector2(525.0, 525.0)
	apply_button.size = Vector2(170.0, 48.0)
	apply_button.pressed.connect(apply_army_doctrine_from_ui)
	apply_button_style(apply_button, UI_GREEN)
	doctrine_panel.add_child(apply_button)


	var close_button: Button = Button.new()
	close_button.name = "DoctrineCloseButton"
	close_button.position = Vector2(715.0, 525.0)
	close_button.size = Vector2(145.0, 48.0)
	close_button.pressed.connect(toggle_army_doctrine_panel)
	apply_button_style(close_button, UI_FLESH)
	doctrine_panel.add_child(close_button)


	doctrine_panel.visible = false
	update_army_doctrine_ui()


func create_doctrine_spinbox(
	input_name: String,
	input_position: Vector2,
	maximum_value: float
) -> SpinBox:

	var input: SpinBox = SpinBox.new()
	input.name = input_name
	input.position = input_position
	input.size = Vector2(370.0, 48.0)
	input.min_value = 0.0
	input.max_value = maximum_value
	input.step = 1.0
	input.allow_greater = false
	input.allow_lesser = false
	input.update_on_text_changed = true
	input.add_theme_font_size_override("font_size", 16)
	doctrine_panel.add_child(input)
	return input


func toggle_army_doctrine_panel() -> void:

	if doctrine_panel == null:
		return


	if upgrade_panel != null and upgrade_panel.visible:
		doctrine_panel.visible = false
		return


	if factory_panel != null:
		factory_panel.visible = false


	doctrine_panel.visible = not doctrine_panel.visible
	refresh_army_doctrine_status()


func apply_army_doctrine_from_ui() -> void:

	var selected_priority: String = str(
		doctrine_priority_input.get_selected_metadata()
	)
	var applied: bool = apply_army_doctrine_configuration(
		int(round(doctrine_target_skeletons_input.value)),
		int(round(doctrine_target_zombies_input.value)),
		int(round(doctrine_bones_reserve_input.value)),
		int(round(doctrine_flesh_reserve_input.value)),
		selected_priority
	)


	doctrine_validation_label.text = (
		tr("DOCTRINE_SAVED")
		if applied
		else tr("DOCTRINE_TARGET_LIMIT")
	)
	doctrine_validation_label.add_theme_color_override(
		"font_color",
		UI_GREEN if applied else UI_FLESH
	)


func update_army_doctrine_ui() -> void:

	if doctrine_nav_button == null or doctrine_panel == null:
		return


	doctrine_nav_button.text = tr("DOCTRINE_NAV")
	var title_label: Label = doctrine_panel.get_node_or_null(
		"DoctrineTitle"
	) as Label
	var apply_button: Button = doctrine_panel.get_node_or_null(
		"DoctrineApplyButton"
	) as Button
	var close_button: Button = doctrine_panel.get_node_or_null(
		"DoctrineCloseButton"
	) as Button


	if title_label != null:
		title_label.text = tr("DOCTRINE_TITLE")


	doctrine_subtitle_label.text = tr("DOCTRINE_PLANNING_MODE")
	doctrine_target_skeletons_input.prefix = (
		tr("DOCTRINE_TARGET_SKELETONS") + ": "
	)
	doctrine_target_zombies_input.prefix = (
		tr("DOCTRINE_TARGET_ZOMBIES") + ": "
	)
	doctrine_bones_reserve_input.prefix = (
		tr("DOCTRINE_BONES_RESERVE") + ": "
	)
	doctrine_flesh_reserve_input.prefix = (
		tr("DOCTRINE_FLESH_RESERVE") + ": "
	)


	var selected_priority: String = doctrine_priority


	doctrine_priority_input.clear()
	add_doctrine_priority_option(
		"DOCTRINE_PRIORITY_BALANCED",
		ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED
	)
	add_doctrine_priority_option(
		"DOCTRINE_PRIORITY_SKELETONS",
		ARMY_DOCTRINE_POLICY.PRIORITY_SKELETONS
	)
	add_doctrine_priority_option(
		"DOCTRINE_PRIORITY_ZOMBIES",
		ARMY_DOCTRINE_POLICY.PRIORITY_ZOMBIES
	)
	select_doctrine_priority(selected_priority)


	if apply_button != null:
		apply_button.text = tr("DOCTRINE_APPLY")


	if close_button != null:
		close_button.text = tr("FACTORY_CLOSE")


	refresh_army_doctrine_status()


func add_doctrine_priority_option(label_key: String, priority_id: String) -> void:

	var index: int = doctrine_priority_input.item_count
	doctrine_priority_input.add_item(tr(label_key))
	doctrine_priority_input.set_item_metadata(index, priority_id)


func select_doctrine_priority(priority_id: String) -> void:

	for index: int in range(doctrine_priority_input.item_count):
		if str(doctrine_priority_input.get_item_metadata(index)) == priority_id:
			doctrine_priority_input.select(index)
			return


	doctrine_priority_input.select(0)


func refresh_army_doctrine_status() -> void:

	if doctrine_status_label == null:
		return


	if not army_doctrine_configured:
		doctrine_status_label.text = tr("DOCTRINE_NOT_CONFIGURED")
		return


	var deficits: Vector2i = get_army_doctrine_deficits()
	doctrine_status_label.text = (
		tr("DOCTRINE_TARGET_STATUS") % [
			doctrine_target_skeletons,
			doctrine_target_zombies
		]
		+ "\n" + tr("DOCTRINE_CURRENT_STATUS") % [
			skeletons.size(),
			zombies.size()
		]
		+ "\n" + tr("DOCTRINE_MISSING_STATUS") % [
			deficits.x,
			deficits.y
		]
	)


func create_hud_panel(
	panel_name: String,
	panel_rect: Rect2
) -> Panel:

	var panel: Panel = Panel.new()
	panel.name = panel_name
	panel.position = panel_rect.position
	panel.size = panel_rect.size
	panel.z_index = 40
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override(
		"panel",
		create_stylebox(
			UI_PANEL,
			UI_METAL_BORDER,
			3,
			4
		)
	)
	add_child(panel)

	return panel


func create_processing_directive_ui() -> void:

	processing_directive_button_group = ButtonGroup.new()
	processing_directive_button_group.allow_unpress = false


	var directive_ids: Array[String] = [
		PROCESSING_BALANCED,
		PROCESSING_BONE_FOCUS,
		PROCESSING_FLESH_FOCUS
	]
	var directive_accents: Array[Color] = [
		UI_GREEN,
		UI_BONE,
		Color(0.72, 0.25, 0.20, 1.0)
	]
	var start_x: float = 1100.0
	var button_width: float = 245.0
	var button_gap: float = 10.0


	for index: int in range(directive_ids.size()):
		var directive_id: String = directive_ids[index]
		var directive_button: Button = Button.new()
		directive_button.name = (
			"ProcessingDirective"
			+ str(index)
		)
		directive_button.position = Vector2(
			start_x + float(index) * (button_width + button_gap),
			987.0
		)
		directive_button.size = Vector2(button_width, 55.0)
		directive_button.z_index = 110
		directive_button.toggle_mode = true
		directive_button.button_group = processing_directive_button_group
		directive_button.add_theme_font_size_override("font_size", 14)
		apply_button_style(
			directive_button,
			directive_accents[index]
		)
		directive_button.pressed.connect(
			set_processing_directive.bind(directive_id)
		)
		add_child(directive_button)
		processing_directive_buttons[directive_id] = directive_button


	update_processing_directive_buttons()


func update_processing_directive_buttons() -> void:

	for directive_id: String in processing_directive_buttons:
		var directive_button: Button = processing_directive_buttons[
			directive_id
		] as Button


		if directive_button == null:
			continue


		var directive_yield: Vector2i = get_processing_yield(
			directive_id
		)
		directive_button.text = (
			get_processing_directive_name(directive_id)
			+ "\n"
			+ str(directive_yield.x)
			+ "B / "
			+ str(directive_yield.y)
			+ "F"
		)
		directive_button.button_pressed = (
			directive_id == processing_directive
		)
		directive_button.disabled = (
			run_finished
			or processing_directive_locked
		)


func create_stylebox(
	fill_color: Color,
	border_color: Color,
	border_width: int,
	corner_radius: int
) -> StyleBoxFlat:

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0

	return style


func apply_button_style(
	button: Button,
	accent_color: Color
) -> void:

	button.add_theme_stylebox_override(
		"normal",
		create_stylebox(
			UI_PANEL_LIGHT,
			accent_color.darkened(0.48),
			3,
			3
		)
	)
	button.add_theme_stylebox_override(
		"hover",
		create_stylebox(
			Color(0.08, 0.105, 0.08, 0.99),
			accent_color,
			3,
			3
		)
	)
	button.add_theme_stylebox_override(
		"pressed",
		create_stylebox(
			accent_color.darkened(0.72),
			accent_color.lightened(0.15),
			4,
			3
		)
	)
	button.add_theme_stylebox_override(
		"disabled",
		create_stylebox(
			Color(0.035, 0.04, 0.037, 0.92),
			Color(0.13, 0.14, 0.12, 1.0),
			2,
			3
		)
	)
	button.add_theme_color_override("font_color", UI_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override(
		"font_disabled_color",
		Color(0.35, 0.37, 0.33, 1.0)
	)


func update_metrics_ui() -> void:

	if metrics_label == null:
		return


	metrics_label.text = (
		tr("METRICS_TITLE")
		+ "\n\n" + tr("METRICS_ENEMIES_KILLED") + "        "
		+ str(total_enemies_killed)
		+ "\n" + tr("METRICS_CORPSES_PROCESSED") + "  "
		+ str(total_corpses_processed)
		+ "\n" + tr("METRICS_SKELETONS_BUILT") + "       "
		+ str(total_skeletons_created)
		+ "\n" + tr("METRICS_SKELETONS_LOST") + "         "
		+ str(total_skeletons_lost)
		+ "\n" + tr("METRICS_ZOMBIES_BUILT") + "            "
		+ str(total_zombies_created)
		+ "\n" + tr("METRICS_ZOMBIES_LOST") + "              "
		+ str(total_zombies_lost)
		+ "\n" + tr("METRICS_ARMY_ACTIVE") + "                "
		+ str(get_total_undead_count())
	)


	if processing_label != null:
		var directive_yield: Vector2i = get_processing_yield()
		var directive_state: String = (
			tr("PROCESSING_LOCKED_WAVE")
			if processing_directive_locked
			else tr("PROCESSING_CHOOSE_NEXT")
		)
		processing_label.text = (
			tr("PROCESSING_TITLE")
			+ "\n" + tr("PROCESSING_MODE") + ": "
			+ get_processing_directive_name()
			+ "  |  "
			+ directive_state
			+ "  |  " + tr("PROCESSING_CORPSES") + ": "
			+ str(corpses.size())
			+ "\n" + tr("PROCESSING_YIELD") + ": +"
			+ str(directive_yield.x)
			+ " " + tr("RESOURCE_BONES") + "  /  +"
			+ str(directive_yield.y)
			+ " " + tr("RESOURCE_FLESH")
			+ "\n" + tr("PROCESSOR_QUEUE") + ": "
			+ str(corpse_processing_queue.size())
			+ " / " + str(corpse_processor_capacity)
			+ "  |  " + tr("PROCESSOR_THROUGHPUT") + ": "
			+ str(corpse_processor_seconds_per_corpse)
			+ tr("PROCESSOR_SECONDS_PER_CORPSE")
		)


	update_processing_directive_buttons()


# =========================================================
# PRIMARY HUD LAYOUT
# =========================================================

func configure_primary_hud_layout() -> void:

	bones_label.position = Vector2(
		45.0,
		862.0
	)

	bones_label.size = Vector2(
		280.0,
		180.0
	)
	bones_label.z_index = 100

	bones_label.add_theme_font_size_override(
		"font_size",
		18
	)
	bones_label.add_theme_color_override(
		"font_color",
		UI_TEXT
	)


	create_skeleton_button.position = Vector2(
		400.0,
		945.0
	)

	create_skeleton_button.size = Vector2(
		290.0,
		82.0
	)
	create_skeleton_button.z_index = 100

	create_skeleton_button.add_theme_font_size_override(
		"font_size",
		16
	)


	create_zombie_button.position = Vector2(
		735.0,
		945.0
	)

	create_zombie_button.size = Vector2(
		290.0,
		82.0
	)
	create_zombie_button.z_index = 100

	create_zombie_button.add_theme_font_size_override(
		"font_size",
		16
	)


	apply_button_style(create_skeleton_button, UI_BONE)
	apply_button_style(create_zombie_button, UI_FLESH)


	production_quantity_selector.position = Vector2(555.0, 895.0)
	production_quantity_selector.size = Vector2(320.0, 38.0)


# =========================================================
# DEBUG HUD
# =========================================================

func create_debug_hud() -> void:

	debug_label = Label.new()

	debug_label.name = "DebugLabel"

	debug_label.position = Vector2(
		40.0,
		275.0
	)

	debug_label.size = Vector2(
		360.0,
		220.0
	)

	debug_label.add_theme_font_size_override(
		"font_size",
		15
	)

	# F3 mostra/esconde durante o desenvolvimento.
	debug_label.visible = false


	add_child(
		debug_label
	)


func update_debug_ui() -> void:

	if debug_label == null:
		return


	var enemy_text: String = "NONE"


	if is_instance_valid(enemy):

		enemy_text = (
			str(enemies.size())
			+ " ACTIVE | "
			+ str(enemy_types.get(enemy, "enemy")).to_upper()
			+ ": "
			+ str(enemy_hp)
			+ " HP"
		)

	elif wave_transition_in_progress:

		enemy_text = "WAVE COMPLETE"

	elif wave_in_progress:

		enemy_text = "SPAWNING"


	debug_label.text = (
		"DEBUG — F3"
		+ "\nWave: "
		+ str(current_wave)
		+ "\nEnemy: "
		+ enemy_text
		+ "\nSkeletons: "
		+ str(skeletons.size())
		+ "\nZombies: "
		+ str(zombies.size())
		+ "\nArmy: "
		+ str(get_total_undead_count())
		+ "\nCorpses: "
		+ str(corpses.size())
		+ "\nCan Rebuild: "
		+ str(
			bones >= skeleton_cost
			or flesh >= zombie_cost
			or not corpses.is_empty()
		)
		+ "\nBoss: "
		+ str(boss_active)
		+ "\nRun Finished: "
		+ str(run_finished)
	)


# =========================================================
# BONES UI
# =========================================================

func update_bones_ui() -> void:

	# v0.2.0 Resource Foundation:
	# reutilizamos o BonesLabel atual como painel temporário
	# de recursos. Depois ele será substituído pela UI final
	# inspirada no target visual do NecroWorks.
	bones_label.text = (
		tr("HUD_RESOURCES")
		+ "\n" + tr("RESOURCE_BONES") + ": "
		+ str(bones)
		+ "\n" + tr("RESOURCE_FLESH") + ": "
		+ str(flesh)
		+ "\n" + tr("RESOURCE_BLOOD") + ": "
		+ str(blood)
		+ "\n" + tr("RESOURCE_SOULS") + ": "
		+ str(souls)
	)


	var quantity: int = get_selected_production_quantity()
	var skeleton_batch_cost: int = quantity * skeleton_cost
	var zombie_batch_cost: int = quantity * zombie_cost
	var has_batch_capacity: bool = (
		quantity <= get_available_undead_capacity()
	)


	if production_quantity_selector != null:
		production_quantity_selector.prefix = (
			tr("PRODUCTION_QUANTITY") + ": "
		)
		production_quantity_selector.editable = not run_finished


	create_skeleton_button.text = (
		tr("FACTORY_CREATE_SKELETON")
		+ " x" + str(quantity)
		+ "\n" + str(skeleton_batch_cost)
		+ " " + tr("RESOURCE_BONES")
	)


	create_zombie_button.text = (
		tr("FACTORY_CREATE_ZOMBIE")
		+ " x" + str(quantity)
		+ "\n" + str(zombie_batch_cost)
		+ " " + tr("RESOURCE_FLESH")
	)


	create_skeleton_button.disabled = (
		run_finished
		or bones < skeleton_batch_cost
		or not has_batch_capacity
	)


	create_zombie_button.disabled = (
		run_finished
		or flesh < zombie_batch_cost
		or not has_batch_capacity
	)


	update_metrics_ui()
	refresh_army_doctrine_status()
