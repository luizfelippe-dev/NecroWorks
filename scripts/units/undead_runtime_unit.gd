class_name UndeadRuntimeUnit
extends Node2D


@export var unit_type: String = "ghost"
@export var production_family: String = "soul"
@export var combat_role: String = "ranged_support"
@export var maximum_hp: int = 70
@export var damage: int = 16
@export var attack_cooldown: float = 1.35
@export var movement_speed: float = 150.0
@export var attack_range: float = 430.0

var current_hp: int = maximum_hp
var attack_timer: float = 0.0
var ability_timer: float = 0.0
var formation_slot: int = -1
var is_temporary: bool = false
var remaining_lifetime: float = 0.0
var summon_source: String = ""


func reset_runtime() -> void:

	current_hp = maximum_hp
	attack_timer = 0.0
	ability_timer = 0.0
	is_temporary = false
	remaining_lifetime = 0.0
	summon_source = ""


func configure_runtime(
	recipe_id: String,
	family: String,
	role: String,
	max_hp: int,
	base_damage: int,
	cooldown: float,
	speed: float,
	range: float,
	slot: int
) -> void:

	unit_type = recipe_id
	production_family = family
	combat_role = role
	maximum_hp = max_hp
	damage = base_damage
	attack_cooldown = cooldown
	movement_speed = speed
	attack_range = range
	formation_slot = slot
	reset_runtime()


func apply_maximum_hp_increase(amount: int) -> void:

	maximum_hp += amount
	current_hp += amount


func configure_temporary(lifetime: float, source: String) -> void:

	is_temporary = true
	remaining_lifetime = maxf(lifetime, 0.0)
	summon_source = source
