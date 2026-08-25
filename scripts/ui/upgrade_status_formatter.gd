extends RefCounted


const CATALOG: Script = preload("res://scripts/game/upgrade_catalog.gd")


static func format(upgrade_id: String, state: Dictionary, translate: Callable) -> String:
	match upgrade_id:
		CATALOG.SHARPENED_BONES:
			return _text(translate, "UPGRADE_CURRENT_SKELETON_DAMAGE") % state.get("skeleton_damage", 0)
		CATALOG.BONE_PLATING:
			return _text(translate, "UPGRADE_CURRENT_SKELETON_HP") % state.get("skeleton_max_hp", 0)
		CATALOG.EFFICIENT_RECYCLING:
			return _text(translate, "UPGRADE_CURRENT_BONE_YIELD") % state.get("bones_per_corpse", 0)
		CATALOG.RAPID_ASSAULT:
			return _text(translate, "UPGRADE_CURRENT_SKELETON_COOLDOWN") % state.get("skeleton_attack_cooldown", 0.0)
		CATALOG.DEATH_MARCH:
			return _text(translate, "UPGRADE_CURRENT_SKELETON_SPEED") % int(round(float(state.get("skeleton_speed", 0.0))))
		CATALOG.MASS_PRODUCTION:
			return _text(translate, "UPGRADE_CURRENT_SKELETON_COST") % state.get("skeleton_cost", 0)
		CATALOG.HEAVY_BONES:
			return _text(translate, "UPGRADE_CURRENT_HEAVY_BONES") % [
				state.get("skeleton_damage", 0),
				state.get("skeleton_attack_cooldown", 0.0),
			]
		CATALOG.BONE_HARVEST:
			return _chance(translate, state.get("bone_harvest_chance", 0.0))
		CATALOG.REASSEMBLY:
			return _chance(translate, state.get("reassembly_chance", 0.0))
		CATALOG.FINAL_SERVICE:
			return _text(translate, "UPGRADE_CURRENT_DEATH_DAMAGE") % state.get("final_service_damage", 0)
		CATALOG.ROTTEN_BULK, CATALOG.STITCHED_HIDE:
			return _text(translate, "UPGRADE_CURRENT_ZOMBIE_HP") % state.get("zombie_max_hp", 0)
		CATALOG.GRAVE_HUNGER, CATALOG.SEPTIC_STRIKES:
			return _text(translate, "UPGRADE_CURRENT_ZOMBIE_DAMAGE") % state.get("zombie_damage", 0)
		CATALOG.DEAD_WEIGHT:
			return _text(translate, "UPGRADE_CURRENT_DEAD_WEIGHT") % [
				state.get("zombie_max_hp", 0),
				int(round(float(state.get("zombie_speed", 0.0)))),
			]
		CATALOG.CARRION_RECOVERY:
			return _text(translate, "UPGRADE_CURRENT_ZOMBIE_RECOVERY") % state.get("zombie_recovery_per_attack", 0)
		CATALOG.GRAVE_CONTRACT:
			return _text(translate, "UPGRADE_GRAVE_CONTRACT_STATUS") % state.get("lich_summon_cap", 0)
		CATALOG.RAPID_CONJURATION:
			return _text(translate, "UPGRADE_RAPID_CONJURATION_STATUS") % state.get("lich_summon_cooldown", 0.0)
		CATALOG.BOUND_SERVITUDE:
			return _text(translate, "UPGRADE_BOUND_SERVITUDE_STATUS") % state.get("lich_summon_lifetime", 0.0)
		CATALOG.EMERGENCY_RECLAMATION:
			return _text(translate, "UPGRADE_EMERGENCY_RECLAMATION_STATUS")
		CATALOG.FLETCHERS_MARK:
			return _text(translate, "UPGRADE_CURRENT_ARCHER_DAMAGE") % state.get("skeleton_archer_damage", 0)
		CATALOG.HOLLOW_SHAFTS:
			return _text(translate, "UPGRADE_CURRENT_ARCHER_COOLDOWN") % state.get("skeleton_archer_attack_cooldown", 0.0)
		CATALOG.OSSUARY_SCOPE:
			return _text(translate, "UPGRADE_CURRENT_ARCHER_RANGE") % int(state.get("skeleton_archer_effective_range", 0))
		CATALOG.GRAVE_MOMENTUM:
			return _text(translate, "UPGRADE_CURRENT_ZOMBIE_COOLDOWN") % state.get("zombie_attack_cooldown", 0.0)
		CATALOG.SPECTRAL_VOLTAGE:
			return _text(translate, "UPGRADE_CURRENT_GHOST_BONUS_DAMAGE") % state.get("ghost_damage_bonus", 0)
		CATALOG.PHASE_CYCLE:
			return _text(translate, "UPGRADE_CURRENT_GHOST_REDUCTION") % state.get("ghost_cooldown_reduction", 0.0)
		CATALOG.FLESH_PRESERVATION:
			return _text(translate, "UPGRADE_CURRENT_FLESH_YIELD") % state.get("flesh_per_corpse", 0)
		CATALOG.SOUL_SIPHON:
			return _text(translate, "UPGRADE_CURRENT_SOUL_BONUS") % state.get("soul_yield_bonus", 0)
		CATALOG.CRIMSON_TITHE:
			return _text(translate, "UPGRADE_CRIMSON_TITHE_STATUS")
		CATALOG.FORBIDDEN_PATENT:
			return _text(translate, "UPGRADE_FORBIDDEN_PATENT_STATUS")
		_:
			return ""


static func _chance(translate: Callable, value: Variant) -> String:
	return _text(translate, "UPGRADE_CURRENT_CHANCE") % int(round(float(value) * 100.0))


static func _text(translate: Callable, key: String) -> String:
	return str(translate.call(key))
