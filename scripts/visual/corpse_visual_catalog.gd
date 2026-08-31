extends RefCounted


const UNIT_SPRITES: Script = preload("res://scripts/visual/unit_sprite_catalog.gd")


static func get_profile(
	source_archetype: String, source_elite: bool, source_boss: bool
) -> Dictionary:
	var family: String = get_family(source_archetype, source_boss)
	var tint: Color = _get_family_tint(family)
	if source_elite:
		tint = tint.lerp(Color(0.78, 0.48, 0.22, 1.0), 0.25)
	return {
		"family": family,
		"texture": UNIT_SPRITES.get_texture(source_archetype),
		"tint": tint,
		"target_height": 78.0 if source_boss else 58.0,
		"rotation": -0.22 if source_boss else -0.12,
	}


static func get_family(source_archetype: String, source_boss: bool = false) -> String:
	if source_boss:
		match source_archetype:
			"grave_marshal":
				return "grave_marshal_remains"
			"arcane_auditor":
				return "arcane_auditor_remains"
			_:
				return "foreman_remains"
	match source_archetype:
		"mage":
			return "arcane"
		"elf":
			return "agile"
		_:
			return "armored"


static func _get_family_tint(family: String) -> Color:
	match family:
		"arcane", "arcane_auditor_remains":
			return Color(0.58, 0.48, 0.72, 0.82)
		"agile":
			return Color(0.48, 0.58, 0.42, 0.82)
		"grave_marshal_remains":
			return Color(0.58, 0.34, 0.30, 0.88)
		"foreman_remains":
			return Color(0.50, 0.38, 0.26, 0.88)
		_:
			return Color(0.55, 0.53, 0.48, 0.82)
