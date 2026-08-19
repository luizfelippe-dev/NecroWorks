class_name UndeadRuntimeUnit
extends Node2D


@export var unit_type: String = "ghost"
@export var maximum_hp: int = 70
@export var damage: int = 16
@export var attack_cooldown: float = 1.35
@export var movement_speed: float = 150.0
@export var attack_range: float = 430.0

var current_hp: int = maximum_hp
var attack_timer: float = 0.0
var formation_slot: int = -1


func reset_runtime() -> void:

	current_hp = maximum_hp
	attack_timer = 0.0
