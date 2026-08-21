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
signal army_doctrine_automation_changed(enabled: bool)
signal hematic_press_order_queued(queued_units: int)
signal hematic_press_completed(remaining_units: int)
signal soul_extractor_completed(souls_gained: int, remaining_corpses: int)
signal production_order_queued(
	unit_type: String,
	quantity: int,
	total_cost: int
)
signal production_unit_completed(
	unit_type: String,
	remaining_in_order: int
)
signal enemy_ability_triggered(
	archetype_id: String,
	ability_id: String,
	target_count: int
)
signal emergency_reclamation_triggered(
	unit_type: String,
	resource_id: String,
	amount: int
)
signal run_checkpoint_requested(state: Dictionary)
signal run_completed(victory: bool)
signal restart_requested
signal return_to_menu_requested


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
	update_ritual_panel_ui()
	update_wave_ui()
	update_synergy_ui()
	refresh_world_localization()
	update_factory_panel_ui()
	update_army_doctrine_ui()
	refresh_narrative_event_ui()
	if run_end_panel != null and run_end_panel.visible:
		show_run_end_screen()


func refresh_world_localization() -> void:

	for current_enemy: Node2D in enemies:
		if not is_instance_valid(current_enemy):
			continue


		var identity_label: Label = current_enemy.get_node_or_null(
			"IdentityLabel"
		) as Label


		if identity_label != null:
			identity_label.text = get_enemy_display_name(
				str(enemy_types.get(current_enemy, "human_warrior")),
				bool(enemy_elite_flags.get(current_enemy, false))
			)


		var trait_label: Label = current_enemy.get_node_or_null(
			"EliteTraitLabel"
		) as Label
		if trait_label != null:
			trait_label.text = get_enemy_elite_trait_name(
				str(enemy_types.get(current_enemy, "human_warrior"))
			)


	for corpse: Button in corpses:
		if is_instance_valid(corpse):
			var route: String = str(corpse.get_meta("processing_route", ""))
			if route == "soul":
				corpse.text = tr("CORPSE_SOUL_QUEUED")
			elif is_corpse_queued(corpse):
				corpse.text = tr("CORPSE_QUEUED")
			elif get_corpse_soul_value(corpse) > 0:
				corpse.text = tr("CORPSE_ARCANE")
			else:
				corpse.text = tr("CORPSE_LABEL")


# =========================================================
# NÓS DA CENA
# =========================================================

@onready var initial_skeleton: Node2D = $Skeleton
@onready var initial_enemy: Node2D = $Enemy

@onready var bones_label: Label = $BonesLabel
@onready var create_skeleton_button: Button = $CreateSkeletonButton

var create_zombie_button: Button = null
var create_skeleton_archer_button: Button = null
var production_quantity_selector: SpinBox = null
var production_queue_label: Label = null


# =========================================================
# CENAS
# =========================================================

var corpse_scene: PackedScene = preload(
	"res://corpse.tscn"
)
var skeleton_scene: PackedScene = preload(
	"res://skeleton.tscn"
)
var skeleton_archer_scene: PackedScene = preload(
	"res://skeleton_archer.tscn"
)
var enemy_scene: PackedScene = preload(
	"res://enemy.tscn"
)
var ghost_scene: PackedScene = preload(
	"res://ghost.tscn"
)
var lich_scene: PackedScene = preload(
	"res://lich.tscn"
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
const ENEMY_COMBAT_POLICY: Script = preload(
	"res://scripts/game/enemy_combat_policy.gd"
)
const UNDEAD_RECIPE_CATALOG: Script = preload(
	"res://scripts/game/undead_recipe_catalog.gd"
)
const LICH_SUMMON_POLICY: Script = preload(
	"res://scripts/game/lich_summon_policy.gd"
)
const NARRATIVE_EVENT_CATALOG: Script = preload(
	"res://scripts/game/narrative_event_catalog.gd"
)
const PROCESSING_DIRECTIVE_POLICY: Script = preload(
	"res://scripts/economy/processing_directive_policy.gd"
)
const NECROMANTIC_RESOURCE_POLICY: Script = preload(
	"res://scripts/economy/necromantic_resource_policy.gd"
)
const ARMY_DOCTRINE_POLICY: Script = preload(
	"res://scripts/factory/army_doctrine_policy.gd"
)
const UNDEAD_PRODUCTION_POLICY: Script = preload(
	"res://scripts/factory/undead_production_policy.gd"
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


func get_total_queued_undead() -> int:

	return (
		UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			skeleton_production_queue
		)
		+ UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			zombie_production_queue
		)
	)


func get_available_production_capacity() -> int:

	return maxi(
		MAX_UNDEAD
		- get_total_undead_count()
		- get_total_queued_undead(),
		0
	)


func create_skeleton_batch_from_ui() -> void:

	enqueue_skeleton_production(get_selected_production_quantity())


func create_skeleton_archer_batch_from_ui() -> void:

	enqueue_skeleton_archer_production(get_selected_production_quantity())


func create_zombie_batch_from_ui() -> void:

	enqueue_zombie_production(get_selected_production_quantity())


func create_skeleton_batch(quantity: int) -> int:

	if quantity < 1 or quantity > MAX_UNDEAD:
		return 0


	var requested_quantity: int = quantity
	var total_cost: int = requested_quantity * skeleton_cost


	if run_finished:
		return 0


	if requested_quantity > get_available_production_capacity():
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


	if requested_quantity > get_available_production_capacity():
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


func enqueue_skeleton_production(quantity: int) -> bool:

	return enqueue_undead_production_order(
		"skeleton",
		quantity,
		skeleton_cost,
		bones,
		skeleton_production_queue
	)


func enqueue_skeleton_archer_production(quantity: int) -> bool:

	if not skeleton_archer_unlocked:
		return false


	return enqueue_undead_production_order(
		"skeleton_archer",
		quantity,
		skeleton_archer_cost,
		bones,
		skeleton_production_queue
	)


func enqueue_zombie_production(quantity: int) -> bool:

	return enqueue_undead_production_order(
		"zombie",
		quantity,
		zombie_cost,
		flesh,
		zombie_production_queue
	)


func enqueue_undead_production_order(
	unit_type: String,
	quantity: int,
	unit_cost: int,
	available_resource: int,
	queue: Array[Dictionary]
) -> bool:

	if run_finished:
		return false


	if not UNDEAD_PRODUCTION_POLICY.can_enqueue_order(
		quantity,
		unit_cost,
		available_resource,
		get_total_undead_count(),
		get_total_queued_undead(),
		MAX_UNDEAD,
		queue.size(),
		PRODUCTION_QUEUE_MAX_ORDERS
	):
		return false


	var order: Dictionary = UNDEAD_PRODUCTION_POLICY.create_order(
		quantity,
		unit_cost
	)
	order["unit_type"] = unit_type
	var total_cost: int = int(order["total_cost"])
	queue.append(order)


	if unit_type != "zombie":
		bones -= total_cost


		if skeleton_assembler_timer <= 0.0:
			skeleton_assembler_timer = SKELETON_ASSEMBLER_BASE_SECONDS
	else:
		flesh -= total_cost


		if flesh_vat_timer <= 0.0:
			flesh_vat_timer = FLESH_VAT_BASE_SECONDS


	production_order_queued.emit(unit_type, quantity, total_cost)
	update_bones_ui()
	return true


func update_undead_production_queues(delta: float) -> void:

	skeleton_assembler_timer = update_undead_production_queue(
		"skeleton",
		skeleton_production_queue,
		skeleton_assembler_timer,
		SKELETON_ASSEMBLER_BASE_SECONDS,
		delta
	)
	flesh_vat_timer = update_undead_production_queue(
		"zombie",
		zombie_production_queue,
		flesh_vat_timer,
		FLESH_VAT_BASE_SECONDS,
		delta
	)


func update_undead_production_queue(
	unit_type: String,
	queue: Array[Dictionary],
	timer: float,
	cycle_seconds: float,
	delta: float
) -> float:

	if queue.is_empty():
		return 0.0


	var next_timer: float = maxf(timer - delta, 0.0)


	if next_timer > 0.0:
		return next_timer


	if get_available_undead_capacity() <= 0:
		return 0.0


	var order: Dictionary = queue[0]
	var queued_unit_type: String = str(order.get("unit_type", unit_type))
	var produced: bool = (
		create_free_zombie("FLESH VAT")
		if queued_unit_type == "zombie"
		else (
			create_free_skeleton_archer("SKELETON ASSEMBLER")
			if queued_unit_type == "skeleton_archer"
			else create_free_skeleton("SKELETON ASSEMBLER")
		)
	)


	if not produced:
		return 0.0


	var remaining: int = maxi(int(order["remaining"]) - 1, 0)
	order["remaining"] = remaining
	production_unit_completed.emit(queued_unit_type, remaining)


	if remaining <= 0:
		queue.pop_front()
		batch_production_completed.emit(
			queued_unit_type,
			int(order["quantity"]),
			int(order["total_cost"])
		)


	update_bones_ui()
	return cycle_seconds if not queue.is_empty() else 0.0

func create_zombie() -> bool:

	if run_finished:
		return false


	if flesh < zombie_cost:

		print(
			"FLESH INSUFICIENTE!"
		)

		return false


	return create_zombie_internal(false, "MANUAL")


func create_free_zombie(source: String) -> bool:

	return create_zombie_internal(true, source)


func create_zombie_internal(is_free: bool, source: String) -> bool:


	var free_slot: int = (
		get_free_undead_slot()
	)


	if free_slot == -1:

		print(
			"LIMITE DE UNDEAD ATINGIDO!"
		)

		return false


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

		return false


	if not is_free:
		if flesh < zombie_cost:
			zombie_node.queue_free()
			return false


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


	if is_free:
		print("ORIGEM: ", source)


	return true


func register_zombie(
	new_zombie: Node2D,
	slot: int
) -> void:

	zombies.append(
		new_zombie
	)


	configure_undead_runtime(
		new_zombie,
		UNDEAD_RECIPE_CATALOG.ZOMBIE_TANK,
		zombie_max_hp,
		zombie_damage,
		zombie_attack_cooldown,
		zombie_speed,
		58.0,
		slot
	)
	set_runtime_hp(new_zombie, zombie_max_hp, zombie_hps)
	set_runtime_attack_timer(new_zombie, 0.0, zombie_attack_timers)
	set_runtime_slot(new_zombie, slot, zombie_slots)


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


func create_ghost() -> bool:
	return create_ghost_internal(false)


func create_free_ghost() -> bool:
	return create_ghost_internal(true)


func create_ghost_internal(is_free: bool) -> bool:

	if run_finished or (not is_free and souls < ghost_cost):
		return false


	if get_available_production_capacity() <= 0:
		return false


	var free_slot: int = get_free_undead_slot()
	var ghost_node: Node = ghost_scene.instantiate()
	var new_ghost: Node2D = ghost_node as Node2D


	if free_slot < 0 or new_ghost == null:
		ghost_node.queue_free()
		return false


	if not is_free:
		souls -= ghost_cost
	add_child(new_ghost)
	configure_undead_runtime(
		new_ghost,
		UNDEAD_RECIPE_CATALOG.GHOST,
		70 + soul_anchor_level * 25,
		16 + soul_focus_level * 4,
		1.20 if has_synergy(SYNERGY_PHANTOM_CONDUIT) else 1.35,
		150.0,
		430.0,
		free_slot
	)
	new_ghost.position = get_spawn_position(free_slot)
	occupied_undead_slots[free_slot] = true
	ghosts.append(new_ghost)
	ensure_unit_health_bar(
		new_ghost,
		int(new_ghost.get("maximum_hp")),
		int(new_ghost.get("maximum_hp")),
		Color(0.25, 0.75, 0.95, 1.0),
		UNIT_SIZE
	)
	total_ghosts_created += 1
	update_bones_ui()
	update_debug_ui()
	return true


func ghost_attack_enemy(attacking_ghost: Node2D) -> void:

	var target_enemy: Node2D = get_closest_enemy_to_unit(attacking_ghost)


	if target_enemy == null:
		return


	var remaining_hp: int = apply_damage_to_enemy(
		target_enemy,
		get_modified_undead_damage(int(attacking_ghost.get("damage")))
	)
	attacking_ghost.set(
		"attack_timer",
		float(attacking_ghost.get("attack_cooldown"))
	)


	if remaining_hp <= 0:
		kill_enemy(target_enemy)


func kill_ghost(target: Node2D) -> void:

	if not ghosts.has(target):
		return


	try_emergency_reclamation(target)
	occupied_undead_slots.erase(int(target.get("formation_slot")))
	ghosts.erase(target)
	total_ghosts_lost += 1
	target.queue_free()
	update_bones_ui()
	update_debug_ui()


func create_lich() -> bool:
	return create_lich_internal(false)


func create_free_lich() -> bool:
	return create_lich_internal(true)


func create_lich_internal(is_free: bool) -> bool:

	if (
		run_finished
		or not lich_unlocked
		or (not is_free and souls < lich_cost)
		or get_available_production_capacity() <= 0
	):
		return false


	var free_slot: int = get_free_undead_slot()
	var lich_node: Node = lich_scene.instantiate()
	var new_lich: Node2D = lich_node as Node2D
	if free_slot < 0 or new_lich == null:
		lich_node.queue_free()
		return false


	if not is_free:
		souls -= lich_cost
	add_child(new_lich)
	configure_undead_runtime(
		new_lich,
		UNDEAD_RECIPE_CATALOG.LICH,
		90 + soul_anchor_level * 20,
		11 + soul_focus_level * 3,
		1.6,
		125.0,
		350.0,
		free_slot
	)
	var runtime: UndeadRuntimeUnit = get_undead_runtime(new_lich)
	runtime.ability_timer = get_lich_summon_cooldown() * 0.5
	new_lich.position = get_spawn_position(free_slot)
	occupied_undead_slots[free_slot] = true
	liches.append(new_lich)
	ensure_unit_health_bar(
		new_lich,
		runtime.maximum_hp,
		runtime.maximum_hp,
		Color(0.66, 0.28, 0.92, 1.0),
		UNIT_SIZE
	)
	total_liches_created += 1
	update_bones_ui()
	update_debug_ui()
	return true


func lich_attack_enemy(attacking_lich: Node2D) -> void:

	var target_enemy: Node2D = get_closest_enemy_to_unit(attacking_lich)
	var runtime: UndeadRuntimeUnit = get_undead_runtime(attacking_lich)
	if target_enemy == null or runtime == null:
		return


	var remaining_hp: int = apply_damage_to_enemy(
		target_enemy,
		get_modified_undead_damage(runtime.damage)
	)
	runtime.attack_timer = runtime.attack_cooldown
	if remaining_hp <= 0:
		kill_enemy(target_enemy)


func kill_lich(target: Node2D) -> void:

	if not liches.has(target):
		return


	try_emergency_reclamation(target)
	var runtime: UndeadRuntimeUnit = get_undead_runtime(target)
	if runtime != null:
		occupied_undead_slots.erase(runtime.formation_slot)
	liches.erase(target)
	total_liches_lost += 1
	target.queue_free()
	update_bones_ui()
	update_debug_ui()


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
		get_modified_undead_damage(
			get_undead_runtime(attacking_zombie).damage
		)
	)


	if (
		zombie_recovery_per_attack > 0
		and get_undead_runtime(attacking_zombie) != null
	):

		var current_hp: int = get_runtime_hp(
			attacking_zombie,
			zombie_hps
		)


		var recovered_hp: int = mini(
			current_hp + zombie_recovery_per_attack,
			zombie_max_hp
		)
		set_runtime_hp(attacking_zombie, recovered_hp, zombie_hps)
		update_unit_health_bar(
			attacking_zombie,
			recovered_hp,
			zombie_max_hp
		)


	set_runtime_attack_timer(
		attacking_zombie,
		get_undead_runtime(attacking_zombie).attack_cooldown,
		zombie_attack_timers
	)


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


	try_emergency_reclamation(target)
	total_zombies_lost += 1


	var freed_slot: int = get_runtime_slot(target, zombie_slots)


	if freed_slot >= 0:

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
var skeleton_archer_speed: float = 160.0
var zombie_speed: float = 120.0
var enemy_speed: float = 100.0


# =========================================================
# VIDA
# =========================================================

var skeleton_max_hp: int = 100
var skeleton_archer_max_hp: int = 65
var zombie_max_hp: int = 220

var enemy_max_hp: int = 100
var enemy_hp: int = 100


# =========================================================
# DANO
# =========================================================

var skeleton_damage: int = 10
var skeleton_archer_damage: int = 14
var zombie_damage: int = 6
var enemy_damage: int = 8


# =========================================================
# COMBATE
# =========================================================

var skeleton_attack_cooldown: float = 0.7
var skeleton_archer_attack_cooldown: float = 1.1
var skeleton_archer_attack_range: float = 380.0
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
var skeleton_archer_cost: int = 8
var zombie_cost: int = 6
var ghost_cost: int = 4
var lich_cost: int = 8

var blood_extraction_level: int = 0
var blood_infusion_level: int = 0
var soul_focus_level: int = 0
var soul_anchor_level: int = 0
var blood_fervor_active: bool = false
var total_blood_earned: int = 0
var total_souls_earned: int = 0


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
var enemy_attack_counts: Dictionary = {}
var enemy_lane_offsets: Dictionary = {}
var enemy_types: Dictionary = {}
var enemy_elite_flags: Dictionary = {}

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
var return_to_menu_button: Button = null


# =========================================================
# NARRATIVE EVENTS
# =========================================================

var event_decision_in_progress: bool = false
var current_narrative_event_id: String = ""
var narrative_event_choices: Dictionary = {}
var narrative_event_panel: ColorRect = null
var narrative_event_title_label: Label = null
var narrative_event_body_label: Label = null
var narrative_event_buttons: Array[Button] = []


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
const UPGRADE_GRAVE_CONTRACT: String = "grave_contract"
const UPGRADE_RAPID_CONJURATION: String = "rapid_conjuration"
const UPGRADE_BOUND_SERVITUDE: String = "bound_servitude"
const UPGRADE_EMERGENCY_RECLAMATION: String = "emergency_reclamation"

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
var emergency_reclamation_available: bool = true

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
const SYNERGY_CRIMSON_ASSEMBLY: String = "crimson_assembly"
const SYNERGY_PHANTOM_CONDUIT: String = "phantom_conduit"
const SYNERGY_DARK_REFINERY: String = "dark_refinery"
const SYNERGY_SOUL_FOUNDRY: String = "soul_foundry"
const SYNERGY_OSSUARY_BALLISTICS: String = "ossuary_ballistics"

const ASSEMBLY_LINE_CHANCE: float = 0.25
const OVERCLOCK_DOUBLE_STRIKE_CHANCE: float = 0.20
const SECOND_SHIFT_DAMAGE_MULTIPLIER: float = 0.50
const MEAT_SHIELD_TIMER_REDUCTION: float = 0.12
const OSSUARY_BALLISTICS_RANGE_BONUS: float = 80.0

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
var total_ghosts_created: int = 0
var total_ghosts_lost: int = 0
var total_liches_created: int = 0
var total_liches_lost: int = 0
var total_thralls_summoned: int = 0
var total_thralls_expired: int = 0
var total_bones_earned: int = 0
var total_flesh_earned: int = 0


# =========================================================
# SKELETONS
# =========================================================

var skeletons: Array[Node2D] = []
var zombies: Array[Node2D] = []
var ghosts: Array[Node2D] = []
var liches: Array[Node2D] = []
var corpses: Array[Button] = []
var corpse_processing_queue: Array[Dictionary] = []
var skeleton_production_queue: Array[Dictionary] = []
var zombie_production_queue: Array[Dictionary] = []

const CORPSE_PROCESSOR_BASE_CAPACITY: int = 5
const CORPSE_PROCESSOR_BASE_SECONDS: float = 0.65

var corpse_processor_capacity: int = CORPSE_PROCESSOR_BASE_CAPACITY
var corpse_processor_seconds_per_corpse: float = CORPSE_PROCESSOR_BASE_SECONDS
var corpse_processor_timer: float = 0.0

const PRODUCTION_QUEUE_MAX_ORDERS: int = 3
const SKELETON_ASSEMBLER_BASE_SECONDS: float = 0.45
const FLESH_VAT_BASE_SECONDS: float = 0.80
const ARMY_DOCTRINE_SCAN_INTERVAL: float = 0.25

var skeleton_assembler_timer: float = 0.0
var flesh_vat_timer: float = 0.0

const FACTORY_AUTO_COLLECTION_COST: int = 2
const FACTORY_QUEUE_UPGRADE_BASE_COST: int = 1
const FACTORY_SPEED_UPGRADE_BASE_COST: int = 1
const FACTORY_PROCESSOR_UPGRADE_MAX_LEVEL: int = 3
const FACTORY_AUTO_COLLECTION_SCAN_INTERVAL: float = 0.25
const FACTORY_QUEUE_CAPACITY_PER_LEVEL: int = 2
const FACTORY_PROCESSING_SECONDS_REDUCTION: float = 0.10
const HEMATIC_PRESS_UNLOCK_COST: int = 3
const HEMATIC_PRESS_FLESH_COST: int = 12
const HEMATIC_PRESS_CYCLE_SECONDS: float = 2.0
const HEMATIC_PRESS_QUEUE_CAPACITY: int = 3
const SOUL_EXTRACTOR_UNLOCK_COST: int = 4
const SOUL_EXTRACTOR_BASE_SECONDS: float = 2.5
const SOUL_EXTRACTOR_QUEUE_CAPACITY: int = 3
const FACTORY_EFFICIENCY_BASE_COST: int = 2
const FACTORY_EFFICIENCY_MAX_LEVEL: int = 3
const FACTORY_EFFICIENCY_FLESH_REDUCTION: int = 2
const FACTORY_EFFICIENCY_SOUL_SECONDS_REDUCTION: float = 0.25
const SKELETON_ARCHER_UNLOCK_COST: int = 3
const LICH_BLUEPRINT_UNLOCK_COST: int = 5

var factory_points: int = 0
var factory_queue_upgrade_level: int = 0
var factory_speed_upgrade_level: int = 0
var automatic_corpse_collection_unlocked: bool = false
var automatic_corpse_collection_enabled: bool = false
var automatic_corpse_collection_timer: float = 0.0
var hematic_press_unlocked: bool = false
var hematic_press_queue: int = 0
var hematic_press_timer: float = 0.0
var soul_extractor_unlocked: bool = false
var soul_routing_enabled: bool = false
var soul_extraction_queue: Array[Dictionary] = []
var soul_extractor_timer: float = 0.0
var factory_efficiency_level: int = 0
var skeleton_archer_unlocked: bool = false
var lich_unlocked: bool = false
var lich_summon_cap_bonus: int = 0
var lich_summon_cooldown_reduction: float = 0.0
var lich_summon_lifetime_bonus: float = 0.0

var army_doctrine_configured: bool = false
var doctrine_target_skeletons: int = 0
var doctrine_target_zombies: int = 0
var doctrine_bones_reserve: int = 0
var doctrine_flesh_reserve: int = 0
var doctrine_priority: String = ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED
var army_doctrine_automation_enabled: bool = false
var army_doctrine_automation_timer: float = 0.0

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
var factory_hematic_press_button: Button = null
var factory_soul_extractor_button: Button = null
var factory_efficiency_button: Button = null
var factory_skeleton_archer_button: Button = null
var factory_lich_button: Button = null
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
var doctrine_automation_button: Button = null
var ritual_nav_button: Button = null
var ritual_panel: ColorRect = null
var ritual_status_label: Label = null
var ritual_sacrifice_button: Button = null
var ritual_extraction_button: Button = null
var ritual_infusion_button: Button = null
var ritual_ghost_button: Button = null
var ritual_lich_button: Button = null
var ritual_soul_focus_button: Button = null
var ritual_soul_anchor_button: Button = null

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
	create_narrative_event_ui()
	create_synergy_hud()
	create_run_end_ui()
	create_factory_panel_ui()
	create_army_doctrine_ui()
	create_ritual_panel_ui()


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
	create_skeleton_archer_button.pressed.connect(
		create_skeleton_archer_batch_from_ui
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
	update_undead_production_queues(delta)
	update_hematic_press(delta)
	update_soul_extractor(delta)
	update_army_doctrine_automation(delta)
	refresh_production_queue_status()


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


		var skeleton_timer: float = get_runtime_attack_timer(
			current_skeleton,
			skeleton_attack_timers
		)


		skeleton_timer = maxf(
			skeleton_timer - delta,
			0.0
		)


		set_runtime_attack_timer(
			current_skeleton,
			skeleton_timer,
			skeleton_attack_timers
		)


	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		var zombie_timer: float = get_runtime_attack_timer(
			current_zombie,
			zombie_attack_timers
		)


		zombie_timer = maxf(
			zombie_timer - delta,
			0.0
		)


		set_runtime_attack_timer(
			current_zombie,
			zombie_timer,
			zombie_attack_timers
		)


	for current_ghost: Node2D in ghosts:

		if not is_instance_valid(current_ghost):
			continue


		if not is_instance_valid(enemy):
			break


		current_ghost.set(
			"attack_timer",
			maxf(float(current_ghost.get("attack_timer")) - delta, 0.0)
		)


	for current_lich: Node2D in liches:
		if not is_instance_valid(current_lich):
			continue


		var lich_runtime: UndeadRuntimeUnit = get_undead_runtime(current_lich)
		if lich_runtime != null:
			lich_runtime.attack_timer = maxf(
				lich_runtime.attack_timer - delta,
				0.0
			)


	update_lich_summons(delta)


	# =====================================================
	# GRUPO DE ENEMIES PERSEGUE A FORMAÇÃO
	# =====================================================

	for current_enemy: Node2D in enemies.duplicate():

		if not is_instance_valid(current_enemy):
			continue


		var closest_undead: Node2D = (
			get_enemy_combat_target(current_enemy)
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

			perform_enemy_attack(current_enemy, closest_undead)
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


		if get_runtime_slot(current_skeleton, skeleton_slots) < 0:
			continue


		var skeleton_slot: int = get_runtime_slot(
			current_skeleton,
			skeleton_slots
		)


		var skeleton_target: Vector2 = (
			get_bone_unit_combat_target_position(
				current_skeleton,
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
					get_undead_runtime(current_skeleton).movement_speed * delta
				)
			)

		else:

			var attack_timer: float = get_runtime_attack_timer(
				current_skeleton,
				skeleton_attack_timers
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


		if get_runtime_slot(current_zombie, zombie_slots) < 0:
			continue


		var zombie_slot: int = get_runtime_slot(
			current_zombie,
			zombie_slots
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
					get_undead_runtime(current_zombie).movement_speed * delta
				)
			)

		else:

			var zombie_timer: float = get_runtime_attack_timer(
				current_zombie,
				zombie_attack_timers
			)


			if zombie_timer <= 0.0:

				zombie_attack_enemy(
					current_zombie
				)


	# Ghosts maintain a ranged support line behind physical Undead.
	for current_ghost: Node2D in ghosts:

		if not is_instance_valid(current_ghost):
			continue


		if not is_instance_valid(enemy):
			break


		var ghost_slot: int = int(current_ghost.get("formation_slot"))
		var compact_slot: int = get_compacted_combat_slot(ghost_slot)
		var target_position: Vector2 = Vector2(
			clampf(
				enemy.position.x - float(current_ghost.get("attack_range")),
				SKELETON_COMBAT_MIN_X,
				SKELETON_COMBAT_MAX_X
			),
			clampf(
				ENEMY_LANE_Y + float(compact_slot % 6 - 3) * 55.0,
				SKELETON_COMBAT_MIN_Y,
				SKELETON_COMBAT_MAX_Y
			)
		)


		if current_ghost.position.distance_to(target_position) > 8.0:
			current_ghost.position = current_ghost.position.move_toward(
				target_position,
				float(current_ghost.get("movement_speed")) * delta
			)
		elif float(current_ghost.get("attack_timer")) <= 0.0:
			ghost_attack_enemy(current_ghost)


	# Liches remain behind the army and combine ranged pressure with summons.
	for current_lich: Node2D in liches:
		if not is_instance_valid(current_lich):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_lich)
		var target_enemy: Node2D = get_closest_enemy_to_unit(current_lich)
		if runtime == null or target_enemy == null:
			continue


		var compact_slot: int = get_compacted_combat_slot(runtime.formation_slot)
		var target_position: Vector2 = Vector2(
			clampf(
				target_enemy.position.x - runtime.attack_range,
				SKELETON_COMBAT_MIN_X,
				SKELETON_COMBAT_MAX_X
			),
			clampf(
				ENEMY_LANE_Y + float(compact_slot % 6 - 3) * 55.0,
				SKELETON_COMBAT_MIN_Y,
				SKELETON_COMBAT_MAX_Y
			)
		)
		if current_lich.position.distance_to(target_position) > 8.0:
			current_lich.position = current_lich.position.move_toward(
				target_position,
				runtime.movement_speed * delta
			)
		elif runtime.attack_timer <= 0.0:
			lich_attack_enemy(current_lich)


# =========================================================
# WAVES
# =========================================================

func start_wave(
	wave_number: int,
	existing_enemy: Node2D = null
) -> void:

	current_wave = wave_number
	emergency_reclamation_available = true

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
	enemy_attack_counts.clear()
	enemy_lane_offsets.clear()
	enemy_types.clear()
	enemy_elite_flags.clear()

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
		enemy_attack_counts.erase(current_enemy)
		enemy_lane_offsets.erase(current_enemy)
		enemy_types.erase(current_enemy)
		enemy_elite_flags.erase(current_enemy)


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


	var effective_damage: int = ENEMY_COMBAT_POLICY.get_incoming_damage(
		str(enemy_types.get(target_enemy, "human_warrior")),
		bool(enemy_elite_flags.get(target_enemy, false)),
		damage_amount
	)
	var remaining_hp: int = int(enemy_hps[target_enemy])
	remaining_hp -= effective_damage
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
	var elite_variant: bool = is_elite_wave(current_wave)
	var display_name: String = get_enemy_display_name(
		archetype_id,
		elite_variant
	)
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


	if elite_variant:
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
	enemy_attack_counts[new_enemy] = 0
	enemy_lane_offsets[new_enemy] = lane_offset
	enemy_types[new_enemy] = archetype_id
	enemy_elite_flags[new_enemy] = elite_variant
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
	ensure_enemy_elite_trait_label(
		new_enemy,
		archetype_id,
		elite_variant,
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


func get_bone_unit_combat_target_position(
	unit: Node2D,
	slot: int
) -> Vector2:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)
	if runtime == null or runtime.combat_role != UNDEAD_RECIPE_CATALOG.ROLE_RANGED_DAMAGE:
		return get_combat_target_position(slot)


	var target_enemy: Node2D = get_closest_enemy_to_unit(unit)
	if target_enemy == null:
		return get_spawn_position(slot)


	var formation_target: Vector2 = get_combat_target_position(slot)
	formation_target.x = clampf(
		target_enemy.position.x - runtime.attack_range,
		SKELETON_COMBAT_MIN_X,
		SKELETON_COMBAT_MAX_X
	)
	return formation_target


func get_compacted_combat_slot(
	original_slot: int
) -> int:

	var ordered_slots: Array[int] = []


	# Zombies entram primeiro na formação de combate.
	# Isso faz o tank ocupar naturalmente a linha de frente.
	for current_zombie: Node2D in zombies:

		if not is_instance_valid(current_zombie):
			continue


		var zombie_slot: int = get_runtime_slot(current_zombie, zombie_slots)


		if zombie_slot < 0:
			continue


		ordered_slots.append(zombie_slot)


	# Skeleton Warriors ficam atrás dos Zombies.
	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)
		if (
			runtime != null
			and runtime.combat_role == UNDEAD_RECIPE_CATALOG.ROLE_RANGED_DAMAGE
		):
			continue


		var skeleton_slot: int = get_runtime_slot(
			current_skeleton,
			skeleton_slots
		)


		if skeleton_slot < 0:
			continue


		ordered_slots.append(skeleton_slot)


	# Bone ranged units form a protected line behind melee Skeletons.
	for current_skeleton: Node2D in skeletons:
		if not is_instance_valid(current_skeleton):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)
		if (
			runtime == null
			or runtime.combat_role != UNDEAD_RECIPE_CATALOG.ROLE_RANGED_DAMAGE
		):
			continue


		var skeleton_slot: int = get_runtime_slot(
			current_skeleton,
			skeleton_slots
		)
		if skeleton_slot >= 0:
			ordered_slots.append(skeleton_slot)


	# Ghosts form the ranged rear line.
	for current_ghost: Node2D in ghosts:

		if not is_instance_valid(current_ghost):
			continue


		ordered_slots.append(int(current_ghost.get("formation_slot")))


	for current_lich: Node2D in liches:
		if not is_instance_valid(current_lich):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_lich)
		if runtime != null:
			ordered_slots.append(runtime.formation_slot)


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

func get_undead_runtime(unit: Node2D) -> UndeadRuntimeUnit:

	return unit as UndeadRuntimeUnit


func configure_undead_runtime(
	unit: Node2D,
	recipe_id: String,
	maximum_hp: int,
	base_damage: int,
	attack_cooldown: float,
	movement_speed: float,
	attack_range: float,
	slot: int
) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime == null:
		push_error("Unidade sem UndeadRuntimeUnit: " + unit.name)
		return


	var recipe: Dictionary = UNDEAD_RECIPE_CATALOG.get_recipe(recipe_id)
	runtime.configure_runtime(
		recipe_id,
		str(recipe.get("family", "unknown")),
		str(recipe.get("role", "unknown")),
		maximum_hp,
		base_damage,
		attack_cooldown,
		movement_speed,
		attack_range,
		slot
	)


func get_runtime_hp(unit: Node2D, fallback_state: Dictionary) -> int:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		return runtime.current_hp


	return int(fallback_state.get(unit, 0))


func set_runtime_hp(
	unit: Node2D,
	value: int,
	fallback_state: Dictionary
) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		runtime.current_hp = value


	# Transitional mirror retained for balance tests and save migration.
	fallback_state[unit] = value


func get_runtime_attack_timer(
	unit: Node2D,
	fallback_state: Dictionary
) -> float:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		return runtime.attack_timer


	return float(fallback_state.get(unit, 0.0))


func set_runtime_attack_timer(
	unit: Node2D,
	value: float,
	fallback_state: Dictionary
) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		runtime.attack_timer = value


	fallback_state[unit] = value


func get_runtime_slot(unit: Node2D, fallback_state: Dictionary) -> int:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		return runtime.formation_slot


	return int(fallback_state.get(unit, -1))


func set_runtime_slot(
	unit: Node2D,
	value: int,
	fallback_state: Dictionary
) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)


	if runtime != null:
		runtime.formation_slot = value


	fallback_state[unit] = value


func sync_physical_undead_runtime_profiles() -> void:

	for current_skeleton: Node2D in skeletons:
		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)


		if runtime == null:
			continue


		if runtime.is_temporary:
			continue


		if runtime.unit_type == UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER:
			runtime.damage = skeleton_archer_damage
			runtime.attack_cooldown = skeleton_archer_attack_cooldown
			runtime.movement_speed = skeleton_archer_speed
			runtime.attack_range = get_skeleton_archer_effective_range()
		else:
			runtime.damage = skeleton_damage
			runtime.attack_cooldown = skeleton_attack_cooldown
			runtime.movement_speed = skeleton_speed


	for current_zombie: Node2D in zombies:
		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_zombie)


		if runtime == null:
			continue


		runtime.damage = zombie_damage
		runtime.attack_cooldown = zombie_attack_cooldown
		runtime.movement_speed = zombie_speed

func register_skeleton(
	new_skeleton: Node2D,
	slot: int
) -> void:

	register_bone_unit(
		new_skeleton,
		slot,
		UNDEAD_RECIPE_CATALOG.SKELETON_WARRIOR,
		skeleton_max_hp,
		skeleton_damage,
		skeleton_attack_cooldown,
		skeleton_speed,
		58.0
	)


func register_skeleton_archer(
	new_archer: Node2D,
	slot: int
) -> void:

	register_bone_unit(
		new_archer,
		slot,
		UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER,
		skeleton_archer_max_hp,
		skeleton_archer_damage,
		skeleton_archer_attack_cooldown,
		skeleton_archer_speed,
		get_skeleton_archer_effective_range()
	)


func get_skeleton_archer_effective_range() -> float:

	return (
		skeleton_archer_attack_range
		+ (
			OSSUARY_BALLISTICS_RANGE_BONUS
			if has_synergy(SYNERGY_OSSUARY_BALLISTICS)
			else 0.0
		)
	)


func register_bone_unit(
	new_skeleton: Node2D,
	slot: int,
	recipe_id: String,
	maximum_hp: int,
	base_damage: int,
	attack_cooldown: float,
	movement_speed: float,
	attack_range: float
) -> void:

	skeletons.append(
		new_skeleton
	)


	configure_undead_runtime(
		new_skeleton,
		recipe_id,
		maximum_hp,
		base_damage,
		attack_cooldown,
		movement_speed,
		attack_range,
		slot
	)
	set_runtime_hp(new_skeleton, maximum_hp, skeleton_hps)
	set_runtime_attack_timer(new_skeleton, 0.0, skeleton_attack_timers)
	set_runtime_slot(new_skeleton, slot, skeleton_slots)


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
		maximum_hp,
		maximum_hp,
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
		+ ghosts.size()
		+ liches.size()
	)


func get_skeleton_archer_count() -> int:

	var count: int = 0
	for current_skeleton: Node2D in skeletons:
		if not is_instance_valid(current_skeleton):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)
		if (
			runtime != null
			and runtime.unit_type == UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER
		):
			count += 1


	return count


func get_temporary_thrall_count() -> int:

	var count: int = 0
	for current_skeleton: Node2D in skeletons:
		if not is_instance_valid(current_skeleton):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)
		if runtime != null and runtime.is_temporary:
			count += 1


	return count


func get_lich_summon_cap() -> int:

	return LICH_SUMMON_POLICY.get_effective_cap(lich_summon_cap_bonus)


func get_lich_summon_cooldown() -> float:

	return LICH_SUMMON_POLICY.get_effective_cooldown(
		lich_summon_cooldown_reduction
	)


func get_lich_summon_lifetime() -> float:

	return LICH_SUMMON_POLICY.get_effective_lifetime(
		lich_summon_lifetime_bonus
	)


func try_lich_summon(source_lich: Node2D) -> bool:

	if not LICH_SUMMON_POLICY.can_summon(
		souls,
		get_temporary_thrall_count(),
		get_lich_summon_cap(),
		get_available_production_capacity()
	):
		return false


	var free_slot: int = get_free_undead_slot()
	var thrall_node: Node = skeleton_scene.instantiate()
	var thrall: Node2D = thrall_node as Node2D
	if free_slot < 0 or thrall == null:
		thrall_node.queue_free()
		return false


	souls -= LICH_SUMMON_POLICY.BASE_SOUL_COST
	add_child(thrall)
	var empowered: bool = has_synergy(SYNERGY_SOUL_FOUNDRY)
	register_bone_unit(
		thrall,
		free_slot,
		UNDEAD_RECIPE_CATALOG.LICH_THRALL,
		55 if empowered else 45,
		8 if empowered else 6,
		0.9,
		190.0,
		58.0
	)
	var runtime: UndeadRuntimeUnit = get_undead_runtime(thrall)
	runtime.configure_temporary(
		get_lich_summon_lifetime(),
		str(source_lich.get_instance_id())
	)
	var sprite: Sprite2D = thrall.get_node_or_null("UnitSprite") as Sprite2D
	if sprite != null:
		sprite.modulate = Color(0.72, 0.46, 0.95, 0.82)
	total_thralls_summoned += 1
	update_bones_ui()
	return true


func expire_temporary_thrall(
	thrall: Node2D,
	natural_expiration: bool = true
) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(thrall)
	if runtime == null or not runtime.is_temporary:
		return


	occupied_undead_slots.erase(runtime.formation_slot)
	skeleton_slots.erase(thrall)
	skeleton_hps.erase(thrall)
	skeleton_attack_timers.erase(thrall)
	skeletons.erase(thrall)
	if natural_expiration:
		total_thralls_expired += 1
	thrall.queue_free()
	update_bones_ui()


func update_lich_summons(delta: float) -> void:

	for current_skeleton: Node2D in skeletons.duplicate():
		if not is_instance_valid(current_skeleton):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_skeleton)
		if runtime == null or not runtime.is_temporary:
			continue


		runtime.remaining_lifetime = maxf(runtime.remaining_lifetime - delta, 0.0)
		if runtime.remaining_lifetime <= 0.0:
			expire_temporary_thrall(current_skeleton)


	for current_lich: Node2D in liches:
		if not is_instance_valid(current_lich):
			continue


		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_lich)
		if runtime == null:
			continue


		runtime.ability_timer = maxf(runtime.ability_timer - delta, 0.0)
		if runtime.ability_timer > 0.0:
			continue


		runtime.ability_timer = (
			get_lich_summon_cooldown()
			if try_lich_summon(current_lich)
			else 1.0
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


	for current_ghost: Node2D in ghosts:

		if is_instance_valid(current_ghost):

			units.append(current_ghost)


	for current_lich: Node2D in liches:
		if is_instance_valid(current_lich):
			units.append(current_lich)


	return units


func get_enemy_combat_target(source_enemy: Node2D) -> Node2D:

	var archetype_id: String = str(
		enemy_types.get(source_enemy, "human_warrior")
	)
	var next_attack_count: int = int(
		enemy_attack_counts.get(source_enemy, 0)
	) + 1
	var elite_variant: bool = bool(
		enemy_elite_flags.get(source_enemy, false)
	)


	if (
		archetype_id == "elf"
		and ENEMY_COMBAT_POLICY.is_elf_precision_attack(
			next_attack_count,
			elite_variant
		)
	):
		return get_elf_precision_target(source_enemy)


	return get_closest_undead_to_enemy(source_enemy)


func get_elf_precision_target(source_enemy: Node2D) -> Node2D:

	if not is_instance_valid(source_enemy):
		return null


	var best_target: Node2D = null
	var best_role_priority: int = 999
	var best_hp_ratio: float = INF
	var best_distance: float = INF


	for candidate: Node2D in get_all_undead_units():
		var runtime: UndeadRuntimeUnit = get_undead_runtime(candidate)
		if runtime == null or runtime.current_hp <= 0:
			continue


		var role_priority: int = ENEMY_COMBAT_POLICY.get_elf_role_priority(
			runtime.combat_role
		)
		var hp_ratio: float = (
			float(runtime.current_hp)
			/ float(maxi(runtime.maximum_hp, 1))
		)
		var distance: float = absf(
			source_enemy.position.x - candidate.position.x
		)


		if (
			role_priority < best_role_priority
			or (
				role_priority == best_role_priority
				and hp_ratio < best_hp_ratio
			)
			or (
				role_priority == best_role_priority
				and is_equal_approx(hp_ratio, best_hp_ratio)
				and distance < best_distance
			)
		):
			best_target = candidate
			best_role_priority = role_priority
			best_hp_ratio = hp_ratio
			best_distance = distance


	return best_target


func perform_enemy_attack(attacking_enemy: Node2D, target: Node2D) -> void:

	if not is_instance_valid(attacking_enemy) or not is_instance_valid(target):
		return


	var archetype_id: String = str(
		enemy_types.get(attacking_enemy, "human_warrior")
	)
	var attack_count: int = int(
		enemy_attack_counts.get(attacking_enemy, 0)
	) + 1
	var base_damage: int = int(
		enemy_damages.get(attacking_enemy, enemy_damage)
	)
	var elite_variant: bool = bool(
		enemy_elite_flags.get(attacking_enemy, false)
	)
	enemy_attack_counts[attacking_enemy] = attack_count


	if (
		archetype_id == "mage"
		and ENEMY_COMBAT_POLICY.is_mage_burst_attack(
			attack_count,
			elite_variant
		)
	):
		perform_mage_arcane_burst(
			attacking_enemy,
			target,
			base_damage,
			elite_variant
		)
		return


	if (
		archetype_id == "elf"
		and ENEMY_COMBAT_POLICY.is_elf_precision_attack(
			attack_count,
			elite_variant
		)
	):
		damage_undead(
			target,
			ENEMY_COMBAT_POLICY.get_precision_damage(
				base_damage,
				elite_variant
			),
			"ELF PRECISION"
		)
		show_enemy_ability_feedback(
			attacking_enemy,
			"elf",
			"precision_shot",
			tr(
				"ENEMY_ABILITY_ELITE_PRECISION_SHOT"
				if elite_variant
				else "ENEMY_ABILITY_PRECISION_SHOT"
			),
			1
		)
		return


	damage_undead(target, base_damage, archetype_id.to_upper())


func perform_mage_arcane_burst(
	attacking_mage: Node2D,
	primary_target: Node2D,
	base_damage: int,
	elite_variant: bool = false
) -> void:

	var burst_targets: Array[Node2D] = get_mage_burst_targets(primary_target)
	var splash_damage: int = ENEMY_COMBAT_POLICY.get_splash_damage(
		base_damage,
		elite_variant
	)


	for target_index: int in range(burst_targets.size()):
		var burst_target: Node2D = burst_targets[target_index]
		if not is_instance_valid(burst_target):
			continue


		damage_undead(
			burst_target,
			base_damage if target_index == 0 else splash_damage,
			"MAGE ARCANE BURST"
		)
		if is_instance_valid(burst_target):
			delay_undead_attack(
				burst_target,
				ENEMY_COMBAT_POLICY.get_mage_suppression_delay(elite_variant)
			)


	show_enemy_ability_feedback(
		attacking_mage,
		"mage",
		"arcane_burst",
		tr(
			"ENEMY_ABILITY_ELITE_ARCANE_BURST"
			if elite_variant
			else "ENEMY_ABILITY_ARCANE_BURST"
		),
		burst_targets.size()
	)


func get_mage_burst_targets(primary_target: Node2D) -> Array[Node2D]:

	var result: Array[Node2D] = []
	if not is_instance_valid(primary_target):
		return result


	result.append(primary_target)
	var candidates: Array[Node2D] = []
	for candidate: Node2D in get_all_undead_units():
		if candidate == primary_target or not is_instance_valid(candidate):
			continue


		if (
			candidate.position.distance_to(primary_target.position)
			<= ENEMY_COMBAT_POLICY.MAGE_SPLASH_RADIUS
		):
			candidates.append(candidate)


	while (
		result.size() < ENEMY_COMBAT_POLICY.MAGE_MAX_TARGETS
		and not candidates.is_empty()
	):
		var closest_candidate: Node2D = candidates[0]
		var closest_distance: float = closest_candidate.position.distance_to(
			primary_target.position
		)
		for candidate: Node2D in candidates:
			var candidate_distance: float = candidate.position.distance_to(
				primary_target.position
			)
			if candidate_distance < closest_distance:
				closest_candidate = candidate
				closest_distance = candidate_distance


		result.append(closest_candidate)
		candidates.erase(closest_candidate)


	return result


func delay_undead_attack(target: Node2D, delay: float) -> void:

	var runtime: UndeadRuntimeUnit = get_undead_runtime(target)
	if runtime == null:
		return


	runtime.attack_timer += maxf(delay, 0.0)
	if skeleton_attack_timers.has(target):
		skeleton_attack_timers[target] = runtime.attack_timer
	if zombie_attack_timers.has(target):
		zombie_attack_timers[target] = runtime.attack_timer


func show_enemy_ability_feedback(
	source_enemy: Node2D,
	archetype_id: String,
	ability_id: String,
	message: String,
	target_count: int
) -> void:

	enemy_ability_triggered.emit(archetype_id, ability_id, target_count)
	if not is_instance_valid(source_enemy):
		return


	var previous_feedback: Node = source_enemy.get_node_or_null(
		"AbilityFeedback"
	)
	if previous_feedback != null:
		previous_feedback.queue_free()


	var feedback: Label = Label.new()
	feedback.name = "AbilityFeedback"
	feedback.position = Vector2(-105.0, -132.0)
	feedback.size = Vector2(210.0, 28.0)
	feedback.text = message
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.z_index = 25
	feedback.add_theme_font_size_override("font_size", 13)
	feedback.add_theme_color_override("font_color", Color(0.86, 0.64, 1.0))
	feedback.add_theme_color_override("font_outline_color", Color.BLACK)
	feedback.add_theme_constant_override("outline_size", 4)
	source_enemy.add_child(feedback)


	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "position:y", -162.0, 0.65)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.65)
	tween.chain().tween_callback(feedback.queue_free)


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

		var skeleton_hp: int = get_runtime_hp(target, skeleton_hps)


		skeleton_hp -= damage_amount


		set_runtime_hp(target, skeleton_hp, skeleton_hps)
		update_unit_health_bar(
			target,
			skeleton_hp,
			get_undead_runtime(target).maximum_hp
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

		var zombie_hp: int = get_runtime_hp(target, zombie_hps)


		zombie_hp -= damage_amount


		set_runtime_hp(target, zombie_hp, zombie_hps)
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


		return


	if ghosts.has(target):
		var ghost_hp: int = int(target.get("current_hp")) - damage_amount
		target.set("current_hp", ghost_hp)
		update_unit_health_bar(
			target,
			ghost_hp,
			int(target.get("maximum_hp"))
		)


		if ghost_hp <= 0:
			kill_ghost(target)


		return


	if liches.has(target):
		var runtime: UndeadRuntimeUnit = get_undead_runtime(target)
		if runtime == null:
			return


		runtime.current_hp -= damage_amount
		update_unit_health_bar(
			target,
			runtime.current_hp,
			runtime.maximum_hp
		)
		if runtime.current_hp <= 0:
			kill_lich(target)


func accelerate_skeleton_line_from_zombie_hit() -> void:

	var accelerated_count: int = 0


	for current_skeleton: Node2D in skeletons:

		if not is_instance_valid(current_skeleton):
			continue


		if not skeleton_attack_timers.has(current_skeleton):
			continue


		var current_timer: float = get_runtime_attack_timer(
			current_skeleton,
			skeleton_attack_timers
		)
		set_runtime_attack_timer(
			current_skeleton,
			maxf(current_timer - MEAT_SHIELD_TIMER_REDUCTION, 0.0),
			skeleton_attack_timers
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
		get_modified_undead_damage(
			get_undead_runtime(attacking_skeleton).damage
		)
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
			get_modified_undead_damage(
				get_undead_runtime(attacking_skeleton).damage
			)
		)

		double_strike_triggered = true


	set_runtime_attack_timer(
		attacking_skeleton,
		get_undead_runtime(attacking_skeleton).attack_cooldown,
		skeleton_attack_timers
	)


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


	var current_hp: int = get_runtime_hp(target, skeleton_hps)


	current_hp -= enemy_damage


	set_runtime_hp(target, current_hp, skeleton_hps)
	update_unit_health_bar(
		target,
		current_hp,
		get_undead_runtime(target).maximum_hp
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
# RARE UPGRADE — EMERGENCY RECLAMATION
# =========================================================

func try_emergency_reclamation(target: Node2D) -> bool:

	if (
		get_upgrade_count(UPGRADE_EMERGENCY_RECLAMATION) <= 0
		or not emergency_reclamation_available
	):
		return false


	var runtime: UndeadRuntimeUnit = get_undead_runtime(target)
	if runtime == null or runtime.is_temporary:
		return false


	var resource_id: String = ""
	var resource_key: String = ""
	var refund_amount: int = 0
	var feedback_color: Color = UI_GREEN


	match runtime.unit_type:
		UNDEAD_RECIPE_CATALOG.SKELETON_WARRIOR:
			resource_id = "bones"
			resource_key = "RESOURCE_BONES"
			refund_amount = maxi(1, int(floor(float(skeleton_cost) * 0.5)))
			feedback_color = UI_BONE
		UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER:
			resource_id = "bones"
			resource_key = "RESOURCE_BONES"
			refund_amount = maxi(
				1,
				int(floor(float(skeleton_archer_cost) * 0.5))
			)
			feedback_color = UI_BONE
		UNDEAD_RECIPE_CATALOG.ZOMBIE_TANK:
			resource_id = "flesh"
			resource_key = "RESOURCE_FLESH"
			refund_amount = maxi(1, int(floor(float(zombie_cost) * 0.5)))
			feedback_color = UI_FLESH
		UNDEAD_RECIPE_CATALOG.GHOST:
			resource_id = "souls"
			resource_key = "RESOURCE_SOULS"
			refund_amount = maxi(1, int(floor(float(ghost_cost) * 0.5)))
			feedback_color = Color(0.38, 0.70, 0.95, 1.0)
		UNDEAD_RECIPE_CATALOG.LICH:
			resource_id = "souls"
			resource_key = "RESOURCE_SOULS"
			refund_amount = maxi(1, int(floor(float(lich_cost) * 0.5)))
			feedback_color = Color(0.68, 0.34, 0.94, 1.0)
		_:
			return false


	match resource_id:
		"bones":
			bones += refund_amount
		"flesh":
			flesh += refund_amount
		"souls":
			souls += refund_amount
		_:
			return false


	emergency_reclamation_available = false
	emergency_reclamation_triggered.emit(
		runtime.unit_type,
		resource_id,
		refund_amount
	)
	show_emergency_reclamation_feedback(
		target.position,
		refund_amount,
		tr(resource_key),
		feedback_color
	)
	update_bones_ui()
	return true


func show_emergency_reclamation_feedback(
	world_position: Vector2,
	amount: int,
	resource_name: String,
	feedback_color: Color
) -> void:

	var feedback: Label = Label.new()
	feedback.name = "EmergencyReclamationFeedback"
	feedback.position = world_position + Vector2(-125.0, -80.0)
	feedback.size = Vector2(250.0, 32.0)
	feedback.text = tr("UPGRADE_EMERGENCY_RECLAMATION_FEEDBACK") % [
		amount,
		resource_name,
	]
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.z_index = 360
	feedback.add_theme_font_size_override("font_size", 15)
	feedback.add_theme_color_override("font_color", feedback_color)
	feedback.add_theme_color_override("font_outline_color", Color.BLACK)
	feedback.add_theme_constant_override("outline_size", 5)
	add_child(feedback)


	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "position:y", feedback.position.y - 45.0, 0.9)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(feedback.queue_free)


# =========================================================
# MATAR SKELETON
# =========================================================

func kill_skeleton(
	target: Node2D
) -> void:

	var target_runtime: UndeadRuntimeUnit = get_undead_runtime(target)
	if target_runtime != null and target_runtime.is_temporary:
		expire_temporary_thrall(target, false)
		return


	# -----------------------------------------------------
	# REASSEMBLY
	# -----------------------------------------------------

	if (
		reassembly_chance > 0.0
		and randf() < reassembly_chance
	):

		var runtime: UndeadRuntimeUnit = get_undead_runtime(target)
		var unit_maximum_hp: int = (
			runtime.maximum_hp if runtime != null else skeleton_max_hp
		)
		var revived_hp: int = int(
			ceil(
				float(unit_maximum_hp)
				* REASSEMBLY_HP_FRACTION
			)
		)

		if revived_hp < 1:
			revived_hp = 1


		set_runtime_hp(target, revived_hp, skeleton_hps)
		set_runtime_attack_timer(
			target,
			skeleton_attack_cooldown,
			skeleton_attack_timers
		)
		update_unit_health_bar(
			target,
			revived_hp,
			unit_maximum_hp
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


	try_emergency_reclamation(target)
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

	var freed_slot: int = get_runtime_slot(target, skeleton_slots)


	if freed_slot >= 0:

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

func apply_necromantic_kill_rewards(
	archetype_id: String,
	defeated_elite: bool,
	defeated_boss: bool
) -> Vector2i:

	var rewards: Vector2i = NECROMANTIC_RESOURCE_POLICY.get_kill_rewards(
		archetype_id,
		defeated_elite,
		defeated_boss,
		total_enemies_killed,
		blood_extraction_level
	)
	blood += rewards.x
	souls += rewards.y
	total_blood_earned += rewards.x
	total_souls_earned += rewards.y


	if rewards != Vector2i.ZERO:
		pulse_resources_panel(
			Color(0.75, 0.06, 0.12, 1.0)
			if rewards.x > 0
			else Color(0.25, 0.75, 0.95, 1.0)
		)
		update_bones_ui()


	return rewards


func has_crimson_assembly_synergy() -> bool:

	return blood_extraction_level > 0 and blood_infusion_level > 0


func purchase_blood_extraction_upgrade() -> bool:

	if blood_extraction_level >= 2:
		return false


	var cost: int = 2 + blood_extraction_level


	if blood < cost:
		return false


	blood -= cost
	blood_extraction_level += 1
	refresh_crimson_synergy()
	update_bones_ui()
	return true


func purchase_blood_infusion_upgrade() -> bool:

	if blood_infusion_level >= 2:
		return false


	var cost: int = 2 + blood_infusion_level


	if blood < cost:
		return false


	blood -= cost
	blood_infusion_level += 1
	refresh_crimson_synergy()
	update_bones_ui()
	return true


func refresh_crimson_synergy() -> void:

	if has_crimson_assembly_synergy():
		unlock_synergy(SYNERGY_CRIMSON_ASSEMBLY)


func purchase_soul_focus_upgrade() -> bool:

	if soul_focus_level >= 2:
		return false


	var cost: int = 2 + soul_focus_level


	if souls < cost:
		return false


	souls -= cost
	soul_focus_level += 1
	refresh_phantom_synergy()
	update_bones_ui()
	return true


func purchase_soul_anchor_upgrade() -> bool:

	if soul_anchor_level >= 2:
		return false


	var cost: int = 2 + soul_anchor_level


	if souls < cost:
		return false


	souls -= cost
	soul_anchor_level += 1
	refresh_phantom_synergy()
	update_bones_ui()
	return true


func refresh_phantom_synergy() -> void:

	if soul_focus_level > 0 and soul_anchor_level > 0:
		unlock_synergy(SYNERGY_PHANTOM_CONDUIT)


func get_blood_sacrifice_cost() -> int:

	return NECROMANTIC_RESOURCE_POLICY.get_sacrifice_cost(
		has_crimson_assembly_synergy()
	)


func activate_blood_fervor() -> bool:

	var sacrifice_cost: int = get_blood_sacrifice_cost()


	if run_finished or blood_fervor_active or blood < sacrifice_cost:
		return false


	blood -= sacrifice_cost
	blood_fervor_active = true
	update_bones_ui()
	return true


func get_modified_undead_damage(base_damage: int) -> int:

	if not blood_fervor_active:
		return base_damage


	return maxi(
		int(round(
			float(base_damage)
			* NECROMANTIC_RESOURCE_POLICY.get_fervor_multiplier(
				blood_infusion_level
			)
		)),
		1
	)

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
	var defeated_elite: bool = bool(
		enemy_elite_flags.get(target_enemy, is_elite_wave(current_wave))
	)
	var defeated_archetype: String = str(
		enemy_types.get(target_enemy, "human_warrior")
	)


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
	enemy_attack_counts.erase(dead_enemy)
	enemy_lane_offsets.erase(dead_enemy)
	enemy_types.erase(dead_enemy)
	enemy_elite_flags.erase(dead_enemy)


	if dead_enemy == enemy:
		enemy = null


	if defeated_boss:
		boss_active = false


	spawn_corpse(
		death_position,
		defeated_archetype,
		defeated_elite,
		defeated_boss
	)
	apply_necromantic_kill_rewards(
		defeated_archetype,
		defeated_elite,
		defeated_boss
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
		blood_fervor_active = false
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
	spawn_position: Vector2,
	source_archetype: String = "human_warrior",
	source_elite: bool = false,
	source_boss: bool = false
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
	var soul_value: int = (
		2
		if source_boss
		else (1 if source_archetype in ["mage", "elf"] else 0)
	)
	corpse.set_meta("source_archetype", source_archetype)
	corpse.set_meta("source_elite", source_elite)
	corpse.set_meta("source_boss", source_boss)
	corpse.set_meta("soul_value", soul_value)
	corpse.set_meta("processing_route", "")
	corpse.text = (
		tr("CORPSE_ARCANE") if soul_value > 0 else tr("CORPSE_LABEL")
	)


	corpse.position = (
		spawn_position
	)


	corpse.pressed.connect(

		func() -> void:

			enqueue_corpse_for_selected_route(
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
	corpse.set_meta("processing_route", "material")
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
	for queue_entry: Dictionary in soul_extraction_queue:
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
		if not is_instance_valid(corpse) or is_corpse_queued(corpse):
			continue


		if soul_routing_enabled and get_corpse_soul_value(corpse) > 0:
			enqueue_corpse_for_soul_extraction(corpse)
		elif corpse_processing_queue.size() < corpse_processor_capacity:
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


func purchase_hematic_press() -> bool:

	if hematic_press_unlocked:
		return false


	if factory_points < HEMATIC_PRESS_UNLOCK_COST:
		return false


	factory_points -= HEMATIC_PRESS_UNLOCK_COST
	hematic_press_unlocked = true
	check_factory_synergy_unlocks()
	update_factory_panel_ui()
	return true


func get_hematic_press_flesh_cost() -> int:

	return maxi(
		HEMATIC_PRESS_FLESH_COST
		- factory_efficiency_level * FACTORY_EFFICIENCY_FLESH_REDUCTION
		- (2 if has_synergy(SYNERGY_DARK_REFINERY) else 0),
		4
	)


func enqueue_hematic_press() -> bool:

	var flesh_cost: int = get_hematic_press_flesh_cost()

	if (
		run_finished
		or not hematic_press_unlocked
		or hematic_press_queue >= HEMATIC_PRESS_QUEUE_CAPACITY
		or flesh < flesh_cost
	):
		return false


	flesh -= flesh_cost
	hematic_press_queue += 1
	if hematic_press_timer <= 0.0:
		hematic_press_timer = HEMATIC_PRESS_CYCLE_SECONDS
	hematic_press_order_queued.emit(hematic_press_queue)
	update_bones_ui()
	return true


func purchase_soul_extractor() -> bool:

	if soul_extractor_unlocked or factory_points < SOUL_EXTRACTOR_UNLOCK_COST:
		return false


	factory_points -= SOUL_EXTRACTOR_UNLOCK_COST
	soul_extractor_unlocked = true
	update_factory_panel_ui()
	return true


func toggle_soul_extractor_control() -> void:

	if not soul_extractor_unlocked:
		purchase_soul_extractor()
		return


	soul_routing_enabled = not soul_routing_enabled
	update_factory_panel_ui()


func get_soul_extractor_cycle_seconds() -> float:

	return maxf(
		SOUL_EXTRACTOR_BASE_SECONDS
		- factory_efficiency_level
		* FACTORY_EFFICIENCY_SOUL_SECONDS_REDUCTION,
		1.0
	)


func get_corpse_soul_value(corpse: Button) -> int:

	if not is_instance_valid(corpse):
		return 0


	return maxi(int(corpse.get_meta("soul_value", 0)), 0)


func enqueue_corpse_for_soul_extraction(corpse: Button) -> bool:

	if (
		run_finished
		or not soul_extractor_unlocked
		or not is_instance_valid(corpse)
		or get_corpse_soul_value(corpse) <= 0
		or is_corpse_queued(corpse)
		or soul_extraction_queue.size() >= SOUL_EXTRACTOR_QUEUE_CAPACITY
	):
		return false


	soul_extraction_queue.append({
		"corpse": corpse,
		"souls": get_corpse_soul_value(corpse)
	})
	corpse.disabled = true
	corpse.set_meta("processing_route", "soul")
	corpse.text = tr("CORPSE_SOUL_QUEUED")
	if soul_extraction_queue.size() == 1:
		soul_extractor_timer = get_soul_extractor_cycle_seconds()
	update_factory_panel_ui()
	return true


func enqueue_corpse_for_selected_route(corpse: Button) -> bool:

	if soul_routing_enabled and get_corpse_soul_value(corpse) > 0:
		return enqueue_corpse_for_soul_extraction(corpse)


	return enqueue_corpse_for_processing(corpse)


func update_soul_extractor(delta: float) -> void:

	for index: int in range(soul_extraction_queue.size() - 1, -1, -1):
		if not is_instance_valid(soul_extraction_queue[index].get("corpse")):
			soul_extraction_queue.remove_at(index)


	if soul_extraction_queue.is_empty():
		soul_extractor_timer = 0.0
		return


	soul_extractor_timer = maxf(soul_extractor_timer - delta, 0.0)
	if factory_panel != null and factory_panel.visible:
		update_factory_soul_extractor_button()
	if soul_extractor_timer > 0.0:
		return


	var entry: Dictionary = soul_extraction_queue.pop_front()
	var corpse: Button = entry.get("corpse") as Button
	var souls_gained: int = maxi(int(entry.get("souls", 0)), 0)
	if is_instance_valid(corpse):
		corpses.erase(corpse)
		corpse.queue_free()
		total_corpses_processed += 1
		souls += souls_gained
		total_souls_earned += souls_gained
		soul_extractor_completed.emit(souls_gained, soul_extraction_queue.size())
	soul_extractor_timer = (
		get_soul_extractor_cycle_seconds()
		if not soul_extraction_queue.is_empty()
		else 0.0
	)
	update_bones_ui()


func purchase_factory_efficiency_upgrade() -> bool:

	if factory_efficiency_level >= FACTORY_EFFICIENCY_MAX_LEVEL:
		return false


	var cost: int = FACTORY_EFFICIENCY_BASE_COST + factory_efficiency_level
	if factory_points < cost:
		return false


	factory_points -= cost
	factory_efficiency_level += 1
	check_factory_synergy_unlocks()
	update_factory_panel_ui()
	return true


func purchase_skeleton_archer_blueprint() -> bool:

	if skeleton_archer_unlocked or factory_points < SKELETON_ARCHER_UNLOCK_COST:
		return false


	factory_points -= SKELETON_ARCHER_UNLOCK_COST
	skeleton_archer_unlocked = true
	check_synergy_unlocks()
	update_factory_panel_ui()
	update_bones_ui()
	return true


func purchase_lich_blueprint() -> bool:

	if lich_unlocked or factory_points < LICH_BLUEPRINT_UNLOCK_COST:
		return false


	factory_points -= LICH_BLUEPRINT_UNLOCK_COST
	lich_unlocked = true
	update_factory_panel_ui()
	update_ritual_panel_ui()
	return true


func activate_hematic_press_control() -> void:

	if not hematic_press_unlocked:
		purchase_hematic_press()
		return


	enqueue_hematic_press()


func update_hematic_press(delta: float) -> void:

	if not hematic_press_unlocked or hematic_press_queue <= 0:
		hematic_press_timer = 0.0
		return


	hematic_press_timer = maxf(hematic_press_timer - delta, 0.0)
	if factory_panel != null and factory_panel.visible:
		update_factory_hematic_press_button()
	if hematic_press_timer > 0.0:
		return


	hematic_press_queue -= 1
	blood += 1
	total_blood_earned += 1
	hematic_press_completed.emit(hematic_press_queue)
	hematic_press_timer = (
		HEMATIC_PRESS_CYCLE_SECONDS
		if hematic_press_queue > 0
		else 0.0
	)
	update_bones_ui()


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
	if not army_doctrine_configured:
		set_army_doctrine_automation_enabled(false)


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
		"priority": doctrine_priority,
		"automation_enabled": army_doctrine_automation_enabled
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


func get_army_doctrine_pending_deficits() -> Vector2i:

	return ARMY_DOCTRINE_POLICY.get_deficits(
		doctrine_target_skeletons,
		doctrine_target_zombies,
		skeletons.size() + UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			skeleton_production_queue
		),
		zombies.size() + UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			zombie_production_queue
		)
	)


func set_army_doctrine_automation_enabled(enabled: bool) -> bool:

	if enabled and (not army_doctrine_configured or run_finished):
		return false


	if army_doctrine_automation_enabled == enabled:
		return true


	army_doctrine_automation_enabled = enabled
	army_doctrine_automation_timer = 0.0
	army_doctrine_automation_changed.emit(enabled)
	update_army_doctrine_ui()
	return true


func toggle_army_doctrine_automation() -> void:

	set_army_doctrine_automation_enabled(
		not army_doctrine_automation_enabled
	)


func update_army_doctrine_automation(delta: float) -> void:

	if not army_doctrine_automation_enabled:
		return


	army_doctrine_automation_timer = maxf(
		army_doctrine_automation_timer - delta,
		0.0
	)
	if army_doctrine_automation_timer > 0.0:
		return


	army_doctrine_automation_timer = ARMY_DOCTRINE_SCAN_INTERVAL
	execute_army_doctrine_replenishment()


func execute_army_doctrine_replenishment() -> Vector2i:

	if not army_doctrine_automation_enabled or not army_doctrine_configured:
		return Vector2i.ZERO


	var deficits: Vector2i = get_army_doctrine_pending_deficits()
	var affordable_skeletons: int = 0
	var affordable_zombies: int = 0
	if skeleton_production_queue.size() < PRODUCTION_QUEUE_MAX_ORDERS:
		affordable_skeletons = maxi(
			int(floor(float(bones - doctrine_bones_reserve) / float(skeleton_cost))),
			0
		)
	if zombie_production_queue.size() < PRODUCTION_QUEUE_MAX_ORDERS:
		affordable_zombies = maxi(
			int(floor(float(flesh - doctrine_flesh_reserve) / float(zombie_cost))),
			0
		)


	var plan: Vector2i = ARMY_DOCTRINE_POLICY.get_replenishment_plan(
		deficits,
		affordable_skeletons,
		affordable_zombies,
		get_available_production_capacity(),
		doctrine_priority
	)
	var queued: Vector2i = Vector2i.ZERO
	if plan.x > 0 and enqueue_skeleton_production(plan.x):
		queued.x = plan.x
	if plan.y > 0 and enqueue_zombie_production(plan.y):
		queued.y = plan.y


	refresh_army_doctrine_status()
	return queued

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


func get_enemy_display_name(
	archetype_id: String,
	elite_variant: bool = false
) -> String:

	var base_name: String = ""
	match archetype_id:
		"human_warrior":
			base_name = tr("ENEMY_HUMAN_WARRIOR")
		"mage":
			base_name = tr("ENEMY_MAGE")
		"elf":
			base_name = tr("ENEMY_ELF_SKIRMISHER")
		"foreman":
			base_name = tr("ENEMY_THE_FOREMAN")
		_:
			base_name = archetype_id.replace("_", " ").to_upper()


	return (
		tr("ENEMY_ELITE_NAME") % base_name
		if elite_variant
		else base_name
	)


func get_enemy_elite_trait_name(archetype_id: String) -> String:

	match archetype_id:
		"human_warrior":
			return tr("ENEMY_ELITE_TRAIT_BULWARK")
		"mage":
			return tr("ENEMY_ELITE_TRAIT_OVERCHARGED")
		"elf":
			return tr("ENEMY_ELITE_TRAIT_DEADEYE")
		_:
			return ""


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
	update_ritual_panel_ui()


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


func create_free_skeleton_archer(source: String) -> bool:

	return create_skeleton_archer_internal(true, source)


func create_skeleton_archer_internal(is_free: bool, source: String) -> bool:

	if run_finished or not skeleton_archer_unlocked:
		return false


	var free_slot: int = get_free_undead_slot()
	if free_slot < 0:
		return false


	var archer_node: Node = skeleton_archer_scene.instantiate()
	var new_archer: Node2D = archer_node as Node2D
	if new_archer == null:
		archer_node.queue_free()
		push_error("skeleton_archer.tscn precisa ter Node2D como raiz.")
		return false


	if not is_free:
		if bones < skeleton_archer_cost:
			archer_node.queue_free()
			return false


		bones -= skeleton_archer_cost


	add_child(new_archer)
	register_skeleton_archer(new_archer, free_slot)
	total_skeletons_created += 1
	update_bones_ui()
	update_debug_ui()


	if is_free:
		print("NOVO SKELETON ARCHER CRIADO! | ORIGEM: ", source)


	return true


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


func ensure_enemy_elite_trait_label(
	target_enemy: Node2D,
	archetype_id: String,
	elite_variant: bool,
	accent_color: Color
) -> void:

	if not elite_variant or not is_instance_valid(target_enemy):
		return


	var trait_label: Label = Label.new()
	trait_label.name = "EliteTraitLabel"
	trait_label.position = Vector2(-90.0, -104.0)
	trait_label.size = Vector2(180.0, 18.0)
	trait_label.text = get_enemy_elite_trait_name(archetype_id)
	trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_label.z_index = 25
	trait_label.add_theme_font_size_override("font_size", 10)
	trait_label.add_theme_color_override(
		"font_color",
		accent_color.lightened(0.48)
	)
	trait_label.add_theme_color_override("font_outline_color", Color.BLACK)
	trait_label.add_theme_constant_override("outline_size", 3)
	target_enemy.add_child(trait_label)



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


func create_narrative_event_ui() -> void:
	narrative_event_panel = ColorRect.new()
	narrative_event_panel.name = "NarrativeEventPanel"
	narrative_event_panel.position = Vector2(460.0, 245.0)
	narrative_event_panel.size = Vector2(1000.0, 590.0)
	narrative_event_panel.color = Color(0.018, 0.024, 0.022, 0.992)
	narrative_event_panel.z_index = 720
	narrative_event_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(narrative_event_panel)

	narrative_event_title_label = Label.new()
	narrative_event_title_label.name = "NarrativeEventTitle"
	narrative_event_title_label.position = Vector2(60.0, 38.0)
	narrative_event_title_label.size = Vector2(880.0, 55.0)
	narrative_event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	narrative_event_title_label.add_theme_font_size_override("font_size", 29)
	narrative_event_title_label.add_theme_color_override("font_color", UI_GREEN)
	narrative_event_panel.add_child(narrative_event_title_label)

	narrative_event_body_label = Label.new()
	narrative_event_body_label.name = "NarrativeEventBody"
	narrative_event_body_label.position = Vector2(90.0, 120.0)
	narrative_event_body_label.size = Vector2(820.0, 190.0)
	narrative_event_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	narrative_event_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	narrative_event_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narrative_event_body_label.add_theme_font_size_override("font_size", 20)
	narrative_event_body_label.add_theme_color_override("font_color", UI_TEXT)
	narrative_event_panel.add_child(narrative_event_body_label)

	for index: int in range(2):
		var choice_button := Button.new()
		choice_button.name = "NarrativeChoice" + str(index + 1)
		choice_button.position = Vector2(80.0 + float(index) * 440.0, 350.0)
		choice_button.size = Vector2(400.0, 145.0)
		choice_button.add_theme_font_size_override("font_size", 18)
		choice_button.pressed.connect(select_narrative_event_choice_by_index.bind(index))
		apply_button_style(choice_button, UI_BONE if index == 0 else UI_FLESH)
		narrative_event_panel.add_child(choice_button)
		narrative_event_buttons.append(choice_button)

	narrative_event_panel.visible = false


func show_narrative_event(event_id: String) -> bool:
	var event: Dictionary = NARRATIVE_EVENT_CATALOG.get_event(event_id)
	if event.is_empty() or narrative_event_choices.has(event_id):
		return false

	current_narrative_event_id = event_id
	event_decision_in_progress = true
	if factory_panel != null:
		factory_panel.visible = false
	if doctrine_panel != null:
		doctrine_panel.visible = false
	if ritual_panel != null:
		ritual_panel.visible = false
	narrative_event_panel.visible = true
	refresh_narrative_event_ui()
	return true


func refresh_narrative_event_ui() -> void:
	if narrative_event_panel == null or current_narrative_event_id.is_empty():
		return
	var event: Dictionary = NARRATIVE_EVENT_CATALOG.get_event(
		current_narrative_event_id
	)
	if event.is_empty():
		return
	narrative_event_title_label.text = tr(str(event.get("title_key", "")))
	narrative_event_body_label.text = tr(str(event.get("body_key", "")))
	var choice_ids: Array = event.get("choices", []) as Array
	for index: int in range(narrative_event_buttons.size()):
		var button: Button = narrative_event_buttons[index]
		button.visible = index < choice_ids.size()
		if button.visible:
			var choice: Dictionary = NARRATIVE_EVENT_CATALOG.get_choice(
				str(choice_ids[index])
			)
			button.text = tr(str(choice.get("label_key", "")))


func select_narrative_event_choice_by_index(index: int) -> void:
	if not event_decision_in_progress:
		return
	var event: Dictionary = NARRATIVE_EVENT_CATALOG.get_event(
		current_narrative_event_id
	)
	var choice_ids: Array = event.get("choices", []) as Array
	if index < 0 or index >= choice_ids.size():
		return
	select_narrative_event_choice(str(choice_ids[index]))


func select_narrative_event_choice(choice_id: String) -> bool:
	if (
		not event_decision_in_progress
		or not NARRATIVE_EVENT_CATALOG.is_choice_for_event(
			current_narrative_event_id,
			choice_id
		)
	):
		return false

	var choice: Dictionary = NARRATIVE_EVENT_CATALOG.get_choice(choice_id)
	var rewards: Dictionary = choice.get("rewards", {}) as Dictionary
	var bones_reward: int = maxi(int(rewards.get("bones", 0)), 0)
	var flesh_reward: int = maxi(int(rewards.get("flesh", 0)), 0)
	var blood_reward: int = maxi(int(rewards.get("blood", 0)), 0)
	var souls_reward: int = maxi(int(rewards.get("souls", 0)), 0)
	bones += bones_reward
	flesh += flesh_reward
	blood += blood_reward
	souls += souls_reward
	factory_points += maxi(int(rewards.get("factory_points", 0)), 0)
	total_bones_earned += bones_reward
	total_flesh_earned += flesh_reward
	total_blood_earned += blood_reward
	total_souls_earned += souls_reward
	narrative_event_choices[current_narrative_event_id] = choice_id

	event_decision_in_progress = false
	current_narrative_event_id = ""
	narrative_event_panel.visible = false
	update_bones_ui()
	update_metrics_ui()
	update_factory_panel_ui()
	continue_wave_after_transition()
	return true


func continue_wave_after_transition() -> void:
	run_checkpoint_requested.emit(build_checkpoint_state())
	start_wave(current_wave)


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


	if lich_unlocked:
		for lich_upgrade: String in [
			UPGRADE_GRAVE_CONTRACT,
			UPGRADE_RAPID_CONJURATION,
			UPGRADE_BOUND_SERVITUDE
		]:
			if get_upgrade_count(lich_upgrade) < 2:
				pool.append(lich_upgrade)


	if (
		current_wave >= 8
		and get_upgrade_count(UPGRADE_EMERGENCY_RECLAMATION) == 0
	):
		pool.append(UPGRADE_EMERGENCY_RECLAMATION)


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


	if ritual_panel != null:
		ritual_panel.visible = false


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
			tr("HUD_WAVE") + " "
			+ str(current_wave)
			+ " " + tr("WAVE_COMPLETE")
			+ " — " + tr("WAVE_SELECT_UPGRADE")
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


		if is_rare_upgrade(upgrade_id):
			apply_button_style(button, Color(0.63, 0.30, 0.88, 1.0))
		elif is_zombie_upgrade(upgrade_id):
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


func is_rare_upgrade(upgrade_id: String) -> bool:

	return upgrade_id == UPGRADE_EMERGENCY_RECLAMATION


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
		+ "\n" + tr("UPGRADE_TAKEN") + ": "
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
	var event_id: String = NARRATIVE_EVENT_CATALOG.get_event_id_for_wave(
		current_wave
	)
	if not event_id.is_empty() and show_narrative_event(event_id):
		return
	continue_wave_after_transition()


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
			skeleton_archer_damage = maxi(
				int(ceil(float(skeleton_archer_damage) * 1.25)),
				skeleton_archer_damage + 1
			)


		UPGRADE_BONE_PLATING:

			skeleton_max_hp += 25
			skeleton_archer_max_hp += 25


			for current_skeleton: Node2D in skeletons:

				if not is_instance_valid(
					current_skeleton
				):
					continue


				if not skeleton_hps.has(
					current_skeleton
				):
					continue


				var current_hp: int = get_runtime_hp(
					current_skeleton,
					skeleton_hps
				)
				var runtime: UndeadRuntimeUnit = get_undead_runtime(
					current_skeleton
				)


				if runtime != null and runtime.is_temporary:
					continue


				if runtime != null:
					runtime.apply_maximum_hp_increase(25)
					current_hp = runtime.current_hp
				else:
					current_hp += 25


				set_runtime_hp(
					current_skeleton,
					current_hp,
					skeleton_hps
				)
				update_unit_health_bar(
					current_skeleton,
					current_hp,
					(
						runtime.maximum_hp
						if runtime != null
						else skeleton_max_hp
					)
				)


		UPGRADE_EFFICIENT_RECYCLING:

			bones_per_corpse += 2


		UPGRADE_RAPID_ASSAULT:

			skeleton_attack_cooldown = maxf(
				skeleton_attack_cooldown
				* 0.85,
				MIN_SKELETON_ATTACK_COOLDOWN
			)
			skeleton_archer_attack_cooldown = maxf(
				skeleton_archer_attack_cooldown * 0.85,
				MIN_SKELETON_ATTACK_COOLDOWN
			)


		UPGRADE_DEATH_MARCH:

			skeleton_speed *= 1.20
			skeleton_archer_speed *= 1.20


		UPGRADE_MASS_PRODUCTION:

			skeleton_cost -= 1


			if skeleton_cost < 1:

				skeleton_cost = 1


			skeleton_archer_cost = maxi(skeleton_archer_cost - 1, 1)


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
			skeleton_archer_damage = maxi(
				int(ceil(float(skeleton_archer_damage) * 1.50)),
				skeleton_archer_damage + 1
			)

			# -20% attack speed equivale a
			# aumentar o intervalo entre ataques em 25%.
			skeleton_attack_cooldown *= 1.25
			skeleton_archer_attack_cooldown *= 1.25


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


		UPGRADE_GRAVE_CONTRACT:

			lich_summon_cap_bonus += 2


		UPGRADE_RAPID_CONJURATION:

			lich_summon_cooldown_reduction += 1.5


		UPGRADE_BOUND_SERVITUDE:

			lich_summon_lifetime_bonus += 4.0


		UPGRADE_EMERGENCY_RECLAMATION:

			emergency_reclamation_available = true


		_:

			push_error(
				"Upgrade desconhecido: "
				+ upgrade_id
			)


	sync_physical_undead_runtime_profiles()
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


		var current_hp: int = get_runtime_hp(current_zombie, zombie_hps)
		var runtime: UndeadRuntimeUnit = get_undead_runtime(current_zombie)


		if runtime != null:
			runtime.apply_maximum_hp_increase(amount)
			current_hp = runtime.current_hp
		else:
			current_hp += amount


		set_runtime_hp(current_zombie, current_hp, zombie_hps)
		update_unit_health_bar(
			current_zombie,
			current_hp,
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

		UPGRADE_GRAVE_CONTRACT:
			return tr("UPGRADE_GRAVE_CONTRACT_NAME")

		UPGRADE_RAPID_CONJURATION:
			return tr("UPGRADE_RAPID_CONJURATION_NAME")

		UPGRADE_BOUND_SERVITUDE:
			return tr("UPGRADE_BOUND_SERVITUDE_NAME")

		UPGRADE_EMERGENCY_RECLAMATION:
			return tr("UPGRADE_EMERGENCY_RECLAMATION_NAME")

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

		UPGRADE_GRAVE_CONTRACT:
			return tr("UPGRADE_GRAVE_CONTRACT_DESC")

		UPGRADE_RAPID_CONJURATION:
			return tr("UPGRADE_RAPID_CONJURATION_DESC")

		UPGRADE_BOUND_SERVITUDE:
			return tr("UPGRADE_BOUND_SERVITUDE_DESC")

		UPGRADE_EMERGENCY_RECLAMATION:
			return tr("UPGRADE_EMERGENCY_RECLAMATION_DESC")

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

		UPGRADE_GRAVE_CONTRACT:
			return tr("UPGRADE_GRAVE_CONTRACT_STATUS") % get_lich_summon_cap()

		UPGRADE_RAPID_CONJURATION:
			return tr("UPGRADE_RAPID_CONJURATION_STATUS") % get_lich_summon_cooldown()

		UPGRADE_BOUND_SERVITUDE:
			return tr("UPGRADE_BOUND_SERVITUDE_STATUS") % get_lich_summon_lifetime()

		UPGRADE_EMERGENCY_RECLAMATION:
			return tr("UPGRADE_EMERGENCY_RECLAMATION_STATUS")

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


	if (
		get_upgrade_count(UPGRADE_GRAVE_CONTRACT) > 0
		and get_upgrade_count(UPGRADE_RAPID_CONJURATION) > 0
	):
		unlock_synergy(SYNERGY_SOUL_FOUNDRY)


	if (
		skeleton_archer_unlocked
		and get_upgrade_count(UPGRADE_HEAVY_BONES) > 0
		and get_upgrade_count(UPGRADE_DEATH_MARCH) > 0
	):
		unlock_synergy(SYNERGY_OSSUARY_BALLISTICS)


func check_factory_synergy_unlocks() -> void:

	if hematic_press_unlocked and factory_efficiency_level >= 2:
		unlock_synergy(SYNERGY_DARK_REFINERY)


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


	if synergy_id == SYNERGY_OSSUARY_BALLISTICS:
		sync_physical_undead_runtime_profiles()


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

		SYNERGY_CRIMSON_ASSEMBLY:
			return tr("SYNERGY_CRIMSON_ASSEMBLY")

		SYNERGY_PHANTOM_CONDUIT:
			return tr("SYNERGY_PHANTOM_CONDUIT")

		SYNERGY_DARK_REFINERY:
			return tr("SYNERGY_DARK_REFINERY")

		SYNERGY_SOUL_FOUNDRY:
			return tr("SYNERGY_SOUL_FOUNDRY")

		SYNERGY_OSSUARY_BALLISTICS:
			return tr("SYNERGY_OSSUARY_BALLISTICS")

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

		SYNERGY_CRIMSON_ASSEMBLY:
			return (
				"Hematic Extraction + Crimson Infusion"
				+ "\nBlood Fervor costs 1 less Blood."
			)

		SYNERGY_PHANTOM_CONDUIT:
			return (
				"Spectral Focus + Ethereal Anchor"
				+ "\nGhost attack cooldown is reduced."
			)

		SYNERGY_DARK_REFINERY:
			return (
				"Hematic Press + Industrial Efficiency II"
				+ "\nBlood production costs 2 less Flesh."
			)

		SYNERGY_SOUL_FOUNDRY:
			return tr("SYNERGY_SOUL_FOUNDRY_DESC")

		SYNERGY_OSSUARY_BALLISTICS:
			return tr("SYNERGY_OSSUARY_BALLISTICS_DESC")

		_:
			return ""


func create_synergy_hud() -> void:

	synergy_label = Label.new()

	synergy_label.name = "SynergyLabel"

	synergy_label.position = Vector2(
		1565.0,
		400.0
	)

	synergy_label.size = Vector2(
		305.0,
		300.0
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
			SYNERGY_MEAT_SHIELD_PROTOCOL,
			SYNERGY_CRIMSON_ASSEMBLY,
			SYNERGY_PHANTOM_CONDUIT,
			SYNERGY_DARK_REFINERY,
			SYNERGY_SOUL_FOUNDRY,
			SYNERGY_OSSUARY_BALLISTICS
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


	if get_total_queued_undead() > 0:
		return


	var can_build_skeleton: bool = (
		bones >= skeleton_cost
	)


	var can_build_zombie: bool = (
		flesh >= zombie_cost
	)
	var can_build_ghost: bool = souls >= ghost_cost


	if (
		can_build_skeleton
		or can_build_zombie
		or can_build_ghost
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
		535.0,
		850.0
	)

	restart_run_button.size = Vector2(
		400.0,
		90.0
	)

	restart_run_button.text = tr("RUN_RESTART")

	restart_run_button.pressed.connect(
		restart_run
	)


	run_end_panel.add_child(
		restart_run_button
	)

	return_to_menu_button = Button.new()
	return_to_menu_button.name = "ReturnToMenuButton"
	return_to_menu_button.position = Vector2(985.0, 850.0)
	return_to_menu_button.size = Vector2(400.0, 90.0)
	return_to_menu_button.text = tr("RUN_RETURN_MENU")
	return_to_menu_button.pressed.connect(return_to_main_menu)
	run_end_panel.add_child(return_to_menu_button)


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


	if create_skeleton_archer_button != null:
		create_skeleton_archer_button.disabled = true


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
	run_completed.emit(victory)


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
			tr("RUN_TARGET_ACHIEVED")
			+ "\n" + tr("RUN_FOREMAN_TERMINATED")
		)

	else:

		run_end_title_label.text = (
			tr("RUN_OPERATION_TERMINATED")
			+ "\n" + tr("RUN_LINE_COLLAPSED")
		)


	run_end_summary_label.text = (
		tr("RUN_STATISTICS")
		+ "\n\n" + tr("RUN_PROGRESS")
		+ "\n" + tr("RUN_WAVE_REACHED") + ": "
		+ str(current_wave)
		+ "\n" + tr("METRICS_ENEMIES_KILLED") + ": "
		+ str(total_enemies_killed)
		+ "\n" + tr("METRICS_CORPSES_PROCESSED") + ": "
		+ str(total_corpses_processed)
		+ "\n" + tr("RUN_CORPSES_REMAINING") + ": "
		+ str(corpses.size())
		+ "\n\n" + tr("RUN_UNDEAD_PRODUCTION")
		+ "\n" + tr("METRICS_SKELETONS_BUILT") + ": "
		+ str(total_skeletons_created)
		+ "\n" + tr("METRICS_SKELETONS_LOST") + ": "
		+ str(total_skeletons_lost)
		+ "\n" + tr("RUN_SKELETONS_REVIVED") + ": "
		+ str(total_skeletons_revived)
		+ "\n" + tr("METRICS_ZOMBIES_BUILT") + ": "
		+ str(total_zombies_created)
		+ "\n" + tr("METRICS_ZOMBIES_LOST") + ": "
		+ str(total_zombies_lost)
		+ "\n" + tr("METRICS_GHOSTS_BUILT") + ": "
		+ str(total_ghosts_created)
		+ "\n" + tr("METRICS_GHOSTS_LOST") + ": "
		+ str(total_ghosts_lost)
		+ "\n" + tr("METRICS_LICHES_BUILT") + ": "
		+ str(total_liches_created)
		+ "\n" + tr("METRICS_LICHES_LOST") + ": "
		+ str(total_liches_lost)
		+ "\n" + tr("RUN_THRALLS_SUMMONED") + ": "
		+ str(total_thralls_summoned)
		+ "\n" + tr("RUN_THRALLS_EXPIRED") + ": "
		+ str(total_thralls_expired)
		+ "\n\n" + tr("RUN_ECONOMY")
		+ "\n" + tr("RESOURCE_BONES") + " " + tr("RUN_EARNED") + ": "
		+ str(total_bones_earned)
		+ "\n" + tr("RESOURCE_FLESH") + " " + tr("RUN_EARNED") + ": "
		+ str(total_flesh_earned)
		+ "\n" + tr("RESOURCE_BLOOD") + " " + tr("RUN_EARNED") + ": "
		+ str(total_blood_earned)
		+ "\n" + tr("RESOURCE_SOULS") + " " + tr("RUN_EARNED") + ": "
		+ str(total_souls_earned)
		+ "\n" + tr("RESOURCE_BONES") + " " + tr("RUN_REMAINING") + ": "
		+ str(bones)
		+ "\n" + tr("RESOURCE_FLESH") + " " + tr("RUN_REMAINING") + ": "
		+ str(flesh)
		+ "\n" + tr("RESOURCE_BLOOD") + " " + tr("RUN_REMAINING") + ": "
		+ str(blood)
		+ "\n" + tr("RESOURCE_SOULS") + " " + tr("RUN_REMAINING") + ": "
		+ str(souls)
	)


	run_end_build_label.text = (
		tr("RUN_BUILD_SUMMARY")
		+ "\n\n" + tr("RUN_ARMY_REMAINING") + ": "
		+ str(get_total_undead_count())
		+ "\n" + tr("RUN_UPGRADES_SELECTED") + ": "
		+ str(total_upgrades_selected)
		+ "\n" + tr("RUN_SYNERGIES_UNLOCKED") + ": "
		+ str(active_synergies.size())
		+ "\n\n" + tr("RUN_PROCESSING_ROUTES")
		+ "\n" + tr("PROCESSING_BALANCED") + ": "
		+ str(int(corpses_processed_by_directive[PROCESSING_BALANCED]))
		+ "\n" + tr("PROCESSING_BONE_FOCUS") + ": "
		+ str(int(corpses_processed_by_directive[PROCESSING_BONE_FOCUS]))
		+ "\n" + tr("PROCESSING_FLESH_FOCUS") + ": "
		+ str(int(corpses_processed_by_directive[PROCESSING_FLESH_FOCUS]))
		+ "\n\n"
		+ get_run_synergy_summary()
		+ "\n\n" + tr("RUN_OPERATION_STATUS")
		+ "\n"
		+ get_run_result_message()
	)


	run_end_panel.visible = true
	restart_run_button.text = tr("RUN_RESTART")
	return_to_menu_button.text = tr("RUN_RETURN_MENU")


func get_run_result_message() -> String:

	if run_won:
		return tr("RUN_RESULT_VICTORY")


	return tr("RUN_RESULT_DEFEAT")


func get_run_synergy_summary() -> String:

	if active_synergies.is_empty():

		return tr("SYNERGIES_ACTIVE") + ": " + tr("COMMON_NONE")


	var result: String = tr("SYNERGIES_ACTIVE") + ":"


	var synergy_order: Array[String] = [
		SYNERGY_RECYCLING_PLANT,
		SYNERGY_SECOND_SHIFT,
		SYNERGY_BONE_ASSEMBLY_LINE,
		SYNERGY_OVERCLOCKED_OSSUARY,
		SYNERGY_MEAT_SHIELD_PROTOCOL,
		SYNERGY_CRIMSON_ASSEMBLY,
		SYNERGY_PHANTOM_CONDUIT,
		SYNERGY_DARK_REFINERY,
		SYNERGY_SOUL_FOUNDRY,
		SYNERGY_OSSUARY_BALLISTICS
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


	if not restart_requested.get_connections().is_empty():
		restart_requested.emit()
		return
	get_tree().reload_current_scene()


func return_to_main_menu() -> void:
	if not return_to_menu_requested.get_connections().is_empty():
		return_to_menu_requested.emit()
		return
	get_tree().change_scene_to_file("res://app.tscn")


func build_checkpoint_state() -> Dictionary:
	var army: Dictionary = {
		UNDEAD_RECIPE_CATALOG.SKELETON_WARRIOR: 0,
		UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER: 0,
		UNDEAD_RECIPE_CATALOG.ZOMBIE_TANK: 0,
		UNDEAD_RECIPE_CATALOG.GHOST: 0,
		UNDEAD_RECIPE_CATALOG.LICH: 0,
	}
	for unit_group: Array in [skeletons, zombies, ghosts, liches]:
		for unit: Node2D in unit_group:
			if not is_instance_valid(unit):
				continue
			var runtime: UndeadRuntimeUnit = get_undead_runtime(unit)
			if runtime != null and not runtime.is_temporary:
				army[runtime.unit_type] = int(army.get(runtime.unit_type, 0)) + 1

	return {
		"wave": current_wave,
		"resources": {
			"bones": bones,
			"flesh": flesh,
			"blood": blood,
			"souls": souls,
		},
		"army": army,
		"upgrades": upgrade_counts.duplicate(true),
		"narrative": {
			"choices": narrative_event_choices.duplicate(true),
			"pending_event": current_narrative_event_id,
		},
		"processing_directive": processing_directive,
		"rituals": {
			"blood_extraction_level": blood_extraction_level,
			"blood_infusion_level": blood_infusion_level,
			"soul_focus_level": soul_focus_level,
			"soul_anchor_level": soul_anchor_level,
		},
		"metrics": {
			"enemies_killed": total_enemies_killed,
			"corpses_processed": total_corpses_processed,
			"skeletons_created": total_skeletons_created,
			"skeletons_lost": total_skeletons_lost,
			"skeletons_revived": total_skeletons_revived,
			"zombies_created": total_zombies_created,
			"zombies_lost": total_zombies_lost,
			"ghosts_created": total_ghosts_created,
			"ghosts_lost": total_ghosts_lost,
			"liches_created": total_liches_created,
			"liches_lost": total_liches_lost,
			"thralls_summoned": total_thralls_summoned,
			"thralls_expired": total_thralls_expired,
			"bones_earned": total_bones_earned,
			"flesh_earned": total_flesh_earned,
			"blood_earned": total_blood_earned,
			"souls_earned": total_souls_earned,
			"upgrades_selected": total_upgrades_selected,
		},
		"production": {
			"skeleton_queue": skeleton_production_queue.duplicate(true),
			"zombie_queue": zombie_production_queue.duplicate(true),
			"hematic_press_queue": hematic_press_queue,
		},
		"factory": {
			"points": factory_points,
			"queue_level": factory_queue_upgrade_level,
			"speed_level": factory_speed_upgrade_level,
			"auto_collection_unlocked": automatic_corpse_collection_unlocked,
			"auto_collection_enabled": automatic_corpse_collection_enabled,
			"hematic_press_unlocked": hematic_press_unlocked,
			"soul_extractor_unlocked": soul_extractor_unlocked,
			"soul_routing_enabled": soul_routing_enabled,
			"efficiency_level": factory_efficiency_level,
			"archer_unlocked": skeleton_archer_unlocked,
			"lich_unlocked": lich_unlocked,
		},
		"doctrine": get_army_doctrine_configuration(),
	}


func restore_checkpoint_state(state: Dictionary) -> bool:
	var saved_wave: int = int(state.get("wave", 0))
	if saved_wave < 1:
		return false

	for enemy: Node2D in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	for unit_group: Array in [skeletons, zombies, ghosts, liches]:
		for unit: Node2D in unit_group:
			if is_instance_valid(unit):
				unit.queue_free()
	skeletons.clear()
	zombies.clear()
	ghosts.clear()
	liches.clear()
	occupied_undead_slots.clear()
	var narrative: Dictionary = state.get("narrative", {}) as Dictionary
	narrative_event_choices = (
		narrative.get("choices", {}) as Dictionary
	).duplicate(true)

	upgrade_counts.clear()
	var saved_upgrades: Dictionary = state.get("upgrades", {}) as Dictionary
	for upgrade_id_value: Variant in saved_upgrades:
		var upgrade_id: String = str(upgrade_id_value)
		var count: int = maxi(int(saved_upgrades[upgrade_id_value]), 0)
		for repeat_index: int in range(count):
			apply_upgrade(upgrade_id)
		upgrade_counts[upgrade_id] = count
	check_synergy_unlocks()

	var factory: Dictionary = state.get("factory", {}) as Dictionary
	factory_points = maxi(int(factory.get("points", 0)), 0)
	factory_queue_upgrade_level = maxi(int(factory.get("queue_level", 0)), 0)
	factory_speed_upgrade_level = maxi(int(factory.get("speed_level", 0)), 0)
	automatic_corpse_collection_unlocked = bool(factory.get("auto_collection_unlocked", false))
	automatic_corpse_collection_enabled = bool(factory.get("auto_collection_enabled", false))
	hematic_press_unlocked = bool(factory.get("hematic_press_unlocked", false))
	soul_extractor_unlocked = bool(factory.get("soul_extractor_unlocked", false))
	soul_routing_enabled = bool(factory.get("soul_routing_enabled", false))
	factory_efficiency_level = maxi(int(factory.get("efficiency_level", 0)), 0)
	skeleton_archer_unlocked = bool(factory.get("archer_unlocked", false))
	lich_unlocked = bool(factory.get("lich_unlocked", false))

	var rituals: Dictionary = state.get("rituals", {}) as Dictionary
	blood_extraction_level = maxi(int(rituals.get("blood_extraction_level", 0)), 0)
	blood_infusion_level = maxi(int(rituals.get("blood_infusion_level", 0)), 0)
	soul_focus_level = maxi(int(rituals.get("soul_focus_level", 0)), 0)
	soul_anchor_level = maxi(int(rituals.get("soul_anchor_level", 0)), 0)
	check_synergy_unlocks()

	var army: Dictionary = state.get("army", {}) as Dictionary
	for index: int in range(maxi(int(army.get(UNDEAD_RECIPE_CATALOG.SKELETON_WARRIOR, 0)), 0)):
		create_free_skeleton("CHECKPOINT")
	for index: int in range(maxi(int(army.get(UNDEAD_RECIPE_CATALOG.SKELETON_ARCHER, 0)), 0)):
		create_free_skeleton_archer("CHECKPOINT")
	for index: int in range(maxi(int(army.get(UNDEAD_RECIPE_CATALOG.ZOMBIE_TANK, 0)), 0)):
		create_free_zombie("CHECKPOINT")
	for index: int in range(maxi(int(army.get(UNDEAD_RECIPE_CATALOG.GHOST, 0)), 0)):
		create_free_ghost()
	for index: int in range(maxi(int(army.get(UNDEAD_RECIPE_CATALOG.LICH, 0)), 0)):
		create_free_lich()

	var resources: Dictionary = state.get("resources", {}) as Dictionary
	bones = maxi(int(resources.get("bones", 0)), 0)
	flesh = maxi(int(resources.get("flesh", 0)), 0)
	blood = maxi(int(resources.get("blood", 0)), 0)
	souls = maxi(int(resources.get("souls", 0)), 0)
	processing_directive = str(state.get("processing_directive", PROCESSING_BALANCED))
	if not PROCESSING_DIRECTIVE_POLICY.is_valid(processing_directive):
		processing_directive = PROCESSING_BALANCED

	var production: Dictionary = state.get("production", {}) as Dictionary
	skeleton_production_queue.assign(
		production.get("skeleton_queue", []) as Array
	)
	zombie_production_queue.assign(
		production.get("zombie_queue", []) as Array
	)
	hematic_press_queue = maxi(int(production.get("hematic_press_queue", 0)), 0)

	var metrics: Dictionary = state.get("metrics", {}) as Dictionary
	total_enemies_killed = maxi(int(metrics.get("enemies_killed", 0)), 0)
	total_corpses_processed = maxi(int(metrics.get("corpses_processed", 0)), 0)
	total_skeletons_created = maxi(int(metrics.get("skeletons_created", 0)), 0)
	total_skeletons_lost = maxi(int(metrics.get("skeletons_lost", 0)), 0)
	total_skeletons_revived = maxi(int(metrics.get("skeletons_revived", 0)), 0)
	total_zombies_created = maxi(int(metrics.get("zombies_created", 0)), 0)
	total_zombies_lost = maxi(int(metrics.get("zombies_lost", 0)), 0)
	total_ghosts_created = maxi(int(metrics.get("ghosts_created", 0)), 0)
	total_ghosts_lost = maxi(int(metrics.get("ghosts_lost", 0)), 0)
	total_liches_created = maxi(int(metrics.get("liches_created", 0)), 0)
	total_liches_lost = maxi(int(metrics.get("liches_lost", 0)), 0)
	total_thralls_summoned = maxi(int(metrics.get("thralls_summoned", 0)), 0)
	total_thralls_expired = maxi(int(metrics.get("thralls_expired", 0)), 0)
	total_bones_earned = maxi(int(metrics.get("bones_earned", 0)), 0)
	total_flesh_earned = maxi(int(metrics.get("flesh_earned", 0)), 0)
	total_blood_earned = maxi(int(metrics.get("blood_earned", 0)), 0)
	total_souls_earned = maxi(int(metrics.get("souls_earned", 0)), 0)
	total_upgrades_selected = maxi(int(metrics.get("upgrades_selected", 0)), 0)

	var doctrine: Dictionary = state.get("doctrine", {}) as Dictionary
	apply_army_doctrine_configuration(
		int(doctrine.get("target_skeletons", 0)),
		int(doctrine.get("target_zombies", 0)),
		int(doctrine.get("bones_reserve", 0)),
		int(doctrine.get("flesh_reserve", 0)),
		str(doctrine.get("priority", ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED))
	)
	set_army_doctrine_automation_enabled(
		bool(doctrine.get("automation_enabled", false))
	)

	run_finished = false
	var pending_event: String = str(narrative.get("pending_event", ""))
	if not pending_event.is_empty():
		current_wave = saved_wave
		show_narrative_event(pending_event)
	else:
		start_wave(saved_wave)
	update_bones_ui()
	update_debug_ui()
	update_factory_panel_ui()
	return true


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


	if event_decision_in_progress:
		wave_label.text = (
			wave_title
			+ "\n" + tr("EVENT_DECISION_PENDING")
		)
		return


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
		+ get_enemy_display_name(
			str(enemy_types.get(enemy, "human_warrior")),
			bool(enemy_elite_flags.get(enemy, false))
		)
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


	create_skeleton_archer_button = Button.new()
	create_skeleton_archer_button.name = "CreateSkeletonArcherButton"
	create_skeleton_archer_button.text = "SKELETON ARCHER LOCKED"
	add_child(create_skeleton_archer_button)


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


	production_queue_label = Label.new()
	production_queue_label.name = "ProductionQueueLabel"
	production_queue_label.position = Vector2(390.0, 988.0)
	production_queue_label.size = Vector2(650.0, 18.0)
	production_queue_label.z_index = 110
	production_queue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	production_queue_label.add_theme_font_size_override("font_size", 12)
	production_queue_label.add_theme_color_override("font_color", UI_GREEN)
	add_child(production_queue_label)


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
		Rect2(1540.0, 18.0, 355.0, 360.0)
	)

	create_hud_panel(
		"SynergyPanel",
		Rect2(1540.0, 385.0, 355.0, 330.0)
	)

	resources_panel = create_hud_panel(
		"ResourcesPanel",
		Rect2(20.0, 842.0, 330.0, 170.0)
	)

	create_hud_panel(
		"ProductionPanel",
		Rect2(365.0, 842.0, 700.0, 170.0)
	)

	processing_panel = create_hud_panel(
		"ProcessingPanel",
		Rect2(1080.0, 842.0, 815.0, 170.0)
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
	metrics_label.size = Vector2(305.0, 325.0)
	metrics_label.z_index = 100
	metrics_label.add_theme_font_size_override("font_size", 14)
	metrics_label.add_theme_color_override("font_color", UI_TEXT)
	add_child(metrics_label)

	factory_title_label = Label.new()
	factory_title_label.name = "FactoryTitleLabel"
	factory_title_label.position = Vector2(390.0, 850.0)
	factory_title_label.size = Vector2(650.0, 38.0)
	factory_title_label.text = tr("FACTORY_PRODUCTION_LINE")
	factory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	factory_title_label.z_index = 100
	factory_title_label.add_theme_font_size_override("font_size", 20)
	factory_title_label.add_theme_color_override("font_color", UI_GREEN)
	add_child(factory_title_label)

	processing_label = Label.new()
	processing_label.name = "ProcessingLabel"
	processing_label.position = Vector2(1110.0, 850.0)
	processing_label.size = Vector2(755.0, 78.0)
	processing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	processing_label.z_index = 100
	processing_label.add_theme_font_size_override("font_size", 16)
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
	close_button.position = Vector2(770.0, 22.0)
	close_button.size = Vector2(90.0, 45.0)
	apply_button_style(close_button, UI_FLESH)
	close_button.pressed.connect(toggle_factory_panel)
	factory_panel.add_child(close_button)


	factory_auto_collection_button = create_factory_upgrade_button(
		"FactoryAutoCollectionButton",
		Vector2(40.0, 130.0),
		UI_GREEN
	)
	factory_auto_collection_button.pressed.connect(
		toggle_automatic_corpse_collection
	)


	factory_queue_upgrade_button = create_factory_upgrade_button(
		"FactoryQueueUpgradeButton",
		Vector2(320.0, 130.0),
		UI_BONE
	)
	factory_queue_upgrade_button.pressed.connect(
		purchase_factory_queue_upgrade
	)


	factory_speed_upgrade_button = create_factory_upgrade_button(
		"FactorySpeedUpgradeButton",
		Vector2(600.0, 130.0),
		Color(0.35, 0.62, 0.82, 1.0)
	)
	factory_speed_upgrade_button.pressed.connect(
		purchase_factory_speed_upgrade
	)


	factory_hematic_press_button = create_factory_upgrade_button(
		"FactoryHematicPressButton",
		Vector2(40.0, 320.0),
		Color(0.68, 0.08, 0.14, 1.0)
	)
	factory_hematic_press_button.pressed.connect(
		activate_hematic_press_control
	)


	factory_soul_extractor_button = create_factory_upgrade_button(
		"FactorySoulExtractorButton",
		Vector2(320.0, 320.0),
		Color(0.48, 0.22, 0.72, 1.0)
	)
	factory_soul_extractor_button.pressed.connect(
		toggle_soul_extractor_control
	)


	factory_efficiency_button = create_factory_upgrade_button(
		"FactoryEfficiencyButton",
		Vector2(600.0, 320.0),
		Color(0.72, 0.55, 0.18, 1.0)
	)
	factory_efficiency_button.pressed.connect(
		purchase_factory_efficiency_upgrade
	)


	factory_skeleton_archer_button = Button.new()
	factory_skeleton_archer_button.name = "FactorySkeletonArcherButton"
	factory_skeleton_archer_button.position = Vector2(40.0, 510.0)
	factory_skeleton_archer_button.size = Vector2(330.0, 62.0)
	factory_skeleton_archer_button.add_theme_font_size_override("font_size", 14)
	apply_button_style(factory_skeleton_archer_button, UI_BONE)
	factory_skeleton_archer_button.pressed.connect(
		purchase_skeleton_archer_blueprint
	)
	factory_panel.add_child(factory_skeleton_archer_button)


	factory_lich_button = Button.new()
	factory_lich_button.name = "FactoryLichButton"
	factory_lich_button.position = Vector2(390.0, 510.0)
	factory_lich_button.size = Vector2(330.0, 62.0)
	factory_lich_button.add_theme_font_size_override("font_size", 13)
	apply_button_style(factory_lich_button, Color(0.62, 0.22, 0.82, 1.0))
	factory_lich_button.pressed.connect(purchase_lich_blueprint)
	factory_panel.add_child(factory_lich_button)


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
	button.size = Vector2(260.0, 170.0)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 13)
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


	if ritual_panel != null:
		ritual_panel.visible = false


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
	update_factory_hematic_press_button()
	update_factory_soul_extractor_button()
	update_factory_efficiency_button()
	update_factory_skeleton_archer_button()
	update_factory_lich_button()


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


func update_factory_hematic_press_button() -> void:

	if factory_hematic_press_button == null:
		return


	if not hematic_press_unlocked:
		factory_hematic_press_button.text = (
			tr("FACTORY_HEMATIC_PRESS")
			+ "\n" + tr("FACTORY_HEMATIC_UNLOCK")
			+ "\n" + tr("FACTORY_COST") + ": "
			+ str(HEMATIC_PRESS_UNLOCK_COST) + " "
			+ tr("FACTORY_POINTS")
		)
		factory_hematic_press_button.disabled = (
			factory_points < HEMATIC_PRESS_UNLOCK_COST
		)
		return


	factory_hematic_press_button.text = (
		tr("FACTORY_HEMATIC_PRESS")
		+ "\n" + tr("FACTORY_HEMATIC_QUEUE") + ": "
		+ str(hematic_press_queue) + " / "
		+ str(HEMATIC_PRESS_QUEUE_CAPACITY)
		+ "  |  " + ("%0.1f" % hematic_press_timer) + "s"
		+ "\n" + tr("FACTORY_HEMATIC_PRODUCE")
		+ "\n" + str(get_hematic_press_flesh_cost()) + " "
		+ tr("RESOURCE_FLESH")
	)
	factory_hematic_press_button.disabled = (
		run_finished
		or hematic_press_queue >= HEMATIC_PRESS_QUEUE_CAPACITY
		or flesh < get_hematic_press_flesh_cost()
	)


func update_factory_soul_extractor_button() -> void:

	if factory_soul_extractor_button == null:
		return


	if not soul_extractor_unlocked:
		factory_soul_extractor_button.text = (
			tr("FACTORY_SOUL_EXTRACTOR")
			+ "\n" + tr("FACTORY_SOUL_UNLOCK")
			+ "\n" + tr("FACTORY_COST") + ": "
			+ str(SOUL_EXTRACTOR_UNLOCK_COST) + " "
			+ tr("FACTORY_POINTS")
		)
		factory_soul_extractor_button.disabled = (
			factory_points < SOUL_EXTRACTOR_UNLOCK_COST
		)
		return


	factory_soul_extractor_button.text = (
		tr("FACTORY_SOUL_EXTRACTOR")
		+ "\n" + (
			tr("FACTORY_SOUL_ROUTING_ON")
			if soul_routing_enabled
			else tr("FACTORY_SOUL_ROUTING_OFF")
		)
		+ "\n" + tr("FACTORY_HEMATIC_QUEUE") + ": "
		+ str(soul_extraction_queue.size()) + " / "
		+ str(SOUL_EXTRACTOR_QUEUE_CAPACITY)
		+ "  |  " + ("%0.1f" % soul_extractor_timer) + "s"
	)
	factory_soul_extractor_button.disabled = run_finished


func update_factory_efficiency_button() -> void:

	if factory_efficiency_button == null:
		return


	var at_max: bool = factory_efficiency_level >= FACTORY_EFFICIENCY_MAX_LEVEL
	var cost: int = FACTORY_EFFICIENCY_BASE_COST + factory_efficiency_level
	factory_efficiency_button.text = (
		tr("FACTORY_EFFICIENCY")
		+ "\n" + tr("FACTORY_LEVEL") + ": "
		+ str(factory_efficiency_level) + " / "
		+ str(FACTORY_EFFICIENCY_MAX_LEVEL)
		+ "\n" + tr("FACTORY_EFFICIENCY_EFFECT")
		+ "\n" + (
			tr("FACTORY_MAX_LEVEL")
			if at_max
			else tr("FACTORY_COST") + ": " + str(cost)
		)
	)
	factory_efficiency_button.disabled = at_max or factory_points < cost


func update_factory_skeleton_archer_button() -> void:

	if factory_skeleton_archer_button == null:
		return


	if skeleton_archer_unlocked:
		factory_skeleton_archer_button.text = (
			tr("FACTORY_ARCHER_BLUEPRINT")
			+ "  |  " + tr("FACTORY_ARCHER_UNLOCKED")
		)
		factory_skeleton_archer_button.disabled = true
		return


	factory_skeleton_archer_button.text = (
		tr("FACTORY_ARCHER_BLUEPRINT")
		+ "  |  " + tr("FACTORY_ARCHER_UNLOCK")
		+ "  |  " + tr("FACTORY_COST") + ": "
		+ str(SKELETON_ARCHER_UNLOCK_COST) + " "
		+ tr("FACTORY_POINTS")
	)
	factory_skeleton_archer_button.disabled = (
		run_finished or factory_points < SKELETON_ARCHER_UNLOCK_COST
	)


func update_factory_lich_button() -> void:

	if factory_lich_button == null:
		return


	if lich_unlocked:
		factory_lich_button.text = (
			tr("FACTORY_LICH_BLUEPRINT")
			+ "\n" + tr("FACTORY_LICH_UNLOCKED")
		)
		factory_lich_button.disabled = true
		return


	factory_lich_button.text = (
		tr("FACTORY_LICH_BLUEPRINT")
		+ "\n" + tr("FACTORY_LICH_UNLOCK")
		+ "  |  " + tr("FACTORY_COST") + ": "
		+ str(LICH_BLUEPRINT_UNLOCK_COST)
	)
	factory_lich_button.disabled = (
		run_finished or factory_points < LICH_BLUEPRINT_UNLOCK_COST
	)


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


	doctrine_automation_button = Button.new()
	doctrine_automation_button.name = "DoctrineAutomationButton"
	doctrine_automation_button.position = Vector2(40.0, 525.0)
	doctrine_automation_button.size = Vector2(260.0, 48.0)
	doctrine_automation_button.pressed.connect(toggle_army_doctrine_automation)
	apply_button_style(doctrine_automation_button, UI_BONE)
	doctrine_panel.add_child(doctrine_automation_button)


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


	if ritual_panel != null:
		ritual_panel.visible = false


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


	if doctrine_automation_button != null:
		doctrine_automation_button.text = (
			tr("DOCTRINE_AUTOMATION_PAUSE")
			if army_doctrine_automation_enabled
			else tr("DOCTRINE_AUTOMATION_START")
		)
		doctrine_automation_button.disabled = (
			not army_doctrine_configured or run_finished
		)


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


	var deficits: Vector2i = get_army_doctrine_pending_deficits()
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
		+ "\n" + (
			tr("DOCTRINE_AUTOMATION_RUNNING")
			if army_doctrine_automation_enabled
			else tr("DOCTRINE_AUTOMATION_PAUSED")
		)
	)


func create_ritual_panel_ui() -> void:

	ritual_nav_button = Button.new()
	ritual_nav_button.position = Vector2(400.0, 770.0)
	ritual_nav_button.size = Vector2(180.0, 52.0)
	ritual_nav_button.z_index = 160
	apply_button_style(ritual_nav_button, Color(0.65, 0.08, 0.14, 1.0))
	ritual_nav_button.pressed.connect(toggle_ritual_panel)
	add_child(ritual_nav_button)


	ritual_panel = ColorRect.new()
	ritual_panel.position = Vector2(560.0, 185.0)
	ritual_panel.size = Vector2(800.0, 610.0)
	ritual_panel.color = Color(0.025, 0.012, 0.018, 0.992)
	ritual_panel.z_index = 660
	ritual_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(ritual_panel)


	var title: Label = Label.new()
	title.name = "RitualTitle"
	title.position = Vector2(40.0, 25.0)
	title.size = Vector2(720.0, 44.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.9, 0.35, 0.4, 1.0))
	ritual_panel.add_child(title)


	ritual_status_label = Label.new()
	ritual_status_label.position = Vector2(65.0, 82.0)
	ritual_status_label.size = Vector2(670.0, 105.0)
	ritual_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ritual_status_label.add_theme_font_size_override("font_size", 17)
	ritual_status_label.add_theme_color_override("font_color", UI_TEXT)
	ritual_panel.add_child(ritual_status_label)


	ritual_sacrifice_button = create_ritual_button(Vector2(70.0, 205.0))
	ritual_extraction_button = create_ritual_button(Vector2(415.0, 205.0))
	ritual_infusion_button = create_ritual_button(Vector2(70.0, 325.0))
	ritual_ghost_button = create_ritual_button(Vector2(415.0, 325.0))
	ritual_soul_focus_button = create_ritual_button(Vector2(55.0, 435.0))
	ritual_lich_button = create_ritual_button(Vector2(295.0, 435.0))
	ritual_soul_anchor_button = create_ritual_button(Vector2(535.0, 435.0))
	ritual_soul_focus_button.size = Vector2(210.0, 90.0)
	ritual_lich_button.size = Vector2(210.0, 90.0)
	ritual_soul_anchor_button.size = Vector2(210.0, 90.0)
	ritual_soul_focus_button.add_theme_font_size_override("font_size", 13)
	ritual_lich_button.add_theme_font_size_override("font_size", 13)
	ritual_soul_anchor_button.add_theme_font_size_override("font_size", 13)
	ritual_sacrifice_button.pressed.connect(
		func() -> void:
			activate_blood_fervor()
			update_ritual_panel_ui()
	)
	ritual_extraction_button.pressed.connect(
		func() -> void:
			purchase_blood_extraction_upgrade()
			update_ritual_panel_ui()
	)
	ritual_infusion_button.pressed.connect(
		func() -> void:
			purchase_blood_infusion_upgrade()
			update_ritual_panel_ui()
	)
	ritual_ghost_button.pressed.connect(
		func() -> void:
			create_ghost()
			update_ritual_panel_ui()
	)
	ritual_soul_focus_button.pressed.connect(
		func() -> void:
			purchase_soul_focus_upgrade()
			update_ritual_panel_ui()
	)
	ritual_lich_button.pressed.connect(
		func() -> void:
			create_lich()
			update_ritual_panel_ui()
	)
	ritual_soul_anchor_button.pressed.connect(
		func() -> void:
			purchase_soul_anchor_upgrade()
			update_ritual_panel_ui()
	)


	var close_button: Button = create_ritual_button(Vector2(245.0, 548.0))
	close_button.name = "RitualCloseButton"
	close_button.size = Vector2(310.0, 46.0)
	close_button.pressed.connect(toggle_ritual_panel)
	ritual_panel.visible = false
	update_ritual_panel_ui()


func create_ritual_button(button_position: Vector2) -> Button:

	var button: Button = Button.new()
	button.position = button_position
	button.size = Vector2(315.0, 90.0)
	button.add_theme_font_size_override("font_size", 16)
	apply_button_style(button, Color(0.68, 0.14, 0.2, 1.0))
	ritual_panel.add_child(button)
	return button


func toggle_ritual_panel() -> void:

	if ritual_panel == null:
		return


	if upgrade_panel != null and upgrade_panel.visible:
		ritual_panel.visible = false
		return


	if factory_panel != null:
		factory_panel.visible = false


	if doctrine_panel != null:
		doctrine_panel.visible = false


	ritual_panel.visible = not ritual_panel.visible
	update_ritual_panel_ui()


func update_ritual_panel_ui() -> void:

	if ritual_panel == null:
		return


	ritual_nav_button.text = tr("RITUAL_NAV")
	var title: Label = ritual_panel.get_node_or_null("RitualTitle") as Label
	var close_button: Button = ritual_panel.get_node_or_null(
		"RitualCloseButton"
	) as Button


	if title != null:
		title.text = tr("RITUAL_TITLE")


	if close_button != null:
		close_button.text = tr("FACTORY_CLOSE")


	ritual_status_label.text = tr("RITUAL_STATUS") % [
		blood,
		souls,
		ghosts.size(),
		liches.size(),
		get_temporary_thrall_count(),
		tr("COMMON_YES") if blood_fervor_active else tr("COMMON_NO")
	]
	var sacrifice_cost: int = get_blood_sacrifice_cost()
	var extraction_cost: int = 2 + blood_extraction_level
	var infusion_cost: int = 2 + blood_infusion_level
	var focus_cost: int = 2 + soul_focus_level
	var anchor_cost: int = 2 + soul_anchor_level
	ritual_sacrifice_button.text = tr("RITUAL_SACRIFICE") % sacrifice_cost
	ritual_extraction_button.text = tr("RITUAL_EXTRACTION") % [
		blood_extraction_level,
		extraction_cost
	]
	ritual_infusion_button.text = tr("RITUAL_INFUSION") % [
		blood_infusion_level,
		infusion_cost
	]
	ritual_ghost_button.text = tr("RITUAL_GHOST") % ghost_cost
	ritual_lich_button.text = (
		tr("RITUAL_LICH") % [
			lich_cost,
			get_lich_summon_cap(),
			get_lich_summon_cooldown(),
			LICH_SUMMON_POLICY.BASE_SOUL_COST
		]
		if lich_unlocked
		else tr("RITUAL_LICH_LOCKED")
	)
	ritual_soul_focus_button.text = tr("RITUAL_SOUL_FOCUS") % [
		soul_focus_level,
		focus_cost
	]
	ritual_soul_anchor_button.text = tr("RITUAL_SOUL_ANCHOR") % [
		soul_anchor_level,
		anchor_cost
	]
	ritual_sacrifice_button.disabled = (
		run_finished or blood_fervor_active or blood < sacrifice_cost
	)
	ritual_extraction_button.disabled = (
		blood_extraction_level >= 2 or blood < extraction_cost
	)
	ritual_infusion_button.disabled = (
		blood_infusion_level >= 2 or blood < infusion_cost
	)
	ritual_ghost_button.disabled = (
		run_finished
		or souls < ghost_cost
		or get_available_production_capacity() <= 0
	)
	ritual_lich_button.disabled = (
		run_finished
		or not lich_unlocked
		or souls < lich_cost
		or get_available_production_capacity() <= 0
	)
	ritual_soul_focus_button.disabled = (
		soul_focus_level >= 2 or souls < focus_cost
	)
	ritual_soul_anchor_button.disabled = (
		soul_anchor_level >= 2 or souls < anchor_cost
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
			952.0
		)
		directive_button.size = Vector2(button_width, 55.0)
		directive_button.z_index = 110
		directive_button.toggle_mode = true
		directive_button.button_group = processing_directive_button_group
		directive_button.add_theme_font_size_override("font_size", 13)
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
		+ "\n" + tr("METRICS_GHOSTS_BUILT") + "             "
		+ str(total_ghosts_created)
		+ "\n" + tr("METRICS_GHOSTS_LOST") + "               "
		+ str(total_ghosts_lost)
		+ "\n" + tr("METRICS_LICHES_BUILT") + "               "
		+ str(total_liches_created)
		+ "\n" + tr("METRICS_LICHES_LOST") + "                 "
		+ str(total_liches_lost)
		+ "\n" + tr("METRICS_THRALLS_ACTIVE") + "              "
		+ str(get_temporary_thrall_count())
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
		858.0
	)

	bones_label.size = Vector2(
		280.0,
		145.0
	)
	bones_label.z_index = 100

	bones_label.add_theme_font_size_override(
		"font_size",
		16
	)
	bones_label.add_theme_color_override(
		"font_color",
		UI_TEXT
	)


	create_skeleton_button.position = Vector2(
		390.0,
		930.0
	)

	create_skeleton_button.size = Vector2(
		205.0,
		62.0
	)
	create_skeleton_button.z_index = 100

	create_skeleton_button.add_theme_font_size_override(
		"font_size",
		12
	)


	create_zombie_button.position = Vector2(
		835.0,
		930.0
	)

	create_zombie_button.size = Vector2(
		205.0,
		62.0
	)
	create_zombie_button.z_index = 100

	create_zombie_button.add_theme_font_size_override(
		"font_size",
		12
	)


	create_skeleton_archer_button.position = Vector2(612.0, 930.0)
	create_skeleton_archer_button.size = Vector2(205.0, 62.0)
	create_skeleton_archer_button.z_index = 100
	create_skeleton_archer_button.add_theme_font_size_override("font_size", 12)


	apply_button_style(create_skeleton_button, UI_BONE)
	apply_button_style(create_skeleton_archer_button, Color(0.72, 0.82, 0.58, 1.0))
	apply_button_style(create_zombie_button, UI_FLESH)


	production_quantity_selector.position = Vector2(555.0, 889.0)
	production_quantity_selector.size = Vector2(320.0, 34.0)


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
		+ "\nArchers: "
		+ str(get_skeleton_archer_count())
		+ "\nZombies: "
		+ str(zombies.size())
		+ "\nGhosts: "
		+ str(ghosts.size())
		+ "\nLiches: "
		+ str(liches.size())
		+ "\nThralls: "
		+ str(get_temporary_thrall_count())
		+ "\nArmy: "
		+ str(get_total_undead_count())
		+ "\nCorpses: "
		+ str(corpses.size())
		+ "\nCan Rebuild: "
		+ str(
			bones >= skeleton_cost
			or flesh >= zombie_cost
			or souls >= ghost_cost
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
	var archer_batch_cost: int = quantity * skeleton_archer_cost
	var zombie_batch_cost: int = quantity * zombie_cost
	var has_batch_capacity: bool = (
		quantity <= get_available_production_capacity()
	)


	if production_quantity_selector != null:
		production_quantity_selector.prefix = (
			tr("PRODUCTION_QUANTITY") + ": "
		)
		production_quantity_selector.editable = not run_finished


	create_skeleton_button.text = (
		tr("PRODUCTION_QUEUE_SKELETON")
		+ " x" + str(quantity)
		+ "\n" + str(skeleton_batch_cost)
		+ " " + tr("RESOURCE_BONES")
	)


	create_zombie_button.text = (
		tr("PRODUCTION_QUEUE_ZOMBIE")
		+ " x" + str(quantity)
		+ "\n" + str(zombie_batch_cost)
		+ " " + tr("RESOURCE_FLESH")
	)


	create_skeleton_archer_button.text = (
		(
			tr("PRODUCTION_QUEUE_ARCHER")
			if skeleton_archer_unlocked
			else tr("PRODUCTION_ARCHER_LOCKED")
		)
		+ " x" + str(quantity)
		+ "\n" + str(archer_batch_cost)
		+ " " + tr("RESOURCE_BONES")
	)


	create_skeleton_button.disabled = (
		run_finished
		or bones < skeleton_batch_cost
		or not has_batch_capacity
		or skeleton_production_queue.size() >= PRODUCTION_QUEUE_MAX_ORDERS
	)


	create_zombie_button.disabled = (
		run_finished
		or flesh < zombie_batch_cost
		or not has_batch_capacity
		or zombie_production_queue.size() >= PRODUCTION_QUEUE_MAX_ORDERS
	)


	create_skeleton_archer_button.disabled = (
		run_finished
		or not skeleton_archer_unlocked
		or bones < archer_batch_cost
		or not has_batch_capacity
		or skeleton_production_queue.size() >= PRODUCTION_QUEUE_MAX_ORDERS
	)


	refresh_production_queue_status()


	update_metrics_ui()
	refresh_army_doctrine_status()
	update_ritual_panel_ui()


func refresh_production_queue_status() -> void:

	if production_queue_label == null:
		return


	production_queue_label.text = tr("PRODUCTION_QUEUE_STATUS") % [
		UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			skeleton_production_queue
		),
		skeleton_assembler_timer,
		UNDEAD_PRODUCTION_POLICY.get_queued_unit_count(
			zombie_production_queue
		),
		flesh_vat_timer
	]
