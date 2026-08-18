extends RefCounted


const BALANCED: String = "balanced"
const BONE_FOCUS: String = "bone_focus"
const FLESH_FOCUS: String = "flesh_focus"

const BONE_FOCUS_BONUS: int = 4
const FLESH_FOCUS_BONE_PENALTY: int = 6
const FLESH_FOCUS_BONUS: int = 4


static func get_yield(
	directive: String,
	bones_per_corpse: int,
	flesh_per_corpse: int
) -> Vector2i:

	match directive:

		BONE_FOCUS:
			return Vector2i(
				bones_per_corpse + BONE_FOCUS_BONUS,
				0
			)

		FLESH_FOCUS:
			return Vector2i(
				maxi(
					bones_per_corpse - FLESH_FOCUS_BONE_PENALTY,
					0
				),
				flesh_per_corpse + FLESH_FOCUS_BONUS
			)

		_:
			return Vector2i(
				bones_per_corpse,
				flesh_per_corpse
			)


static func get_display_name(directive: String) -> String:

	match directive:
		BONE_FOCUS:
			return "BONE FOCUS"
		FLESH_FOCUS:
			return "FLESH FOCUS"
		_:
			return "BALANCED"


static func is_valid(directive: String) -> bool:

	return directive in [
		BALANCED,
		BONE_FOCUS,
		FLESH_FOCUS
	]
