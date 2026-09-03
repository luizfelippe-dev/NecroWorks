extends RefCounted


const SKELETON_IDLE: Texture2D = preload(
	"res://assets/sprites/units/skeleton_warrior_v1/idle.png"
)
const SKELETON_MOVE: Texture2D = preload(
	"res://assets/sprites/units/skeleton_warrior_v1/move.png"
)
const SKELETON_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/skeleton_warrior_v1/attack.png"
)
const SKELETON_HIT: Texture2D = preload(
	"res://assets/sprites/units/skeleton_warrior_v1/hit.png"
)
const SKELETON_DEATH: Texture2D = preload(
	"res://assets/sprites/units/skeleton_warrior_v1/death.png"
)
const SKELETON: Texture2D = SKELETON_IDLE
const SKELETON_ARCHER: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_prototype.png"
)
const ZOMBIE: Texture2D = preload(
	"res://assets/sprites/units/zombie_prototype.png"
)
const HUMAN_WARRIOR: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_prototype.png"
)
const MAGE: Texture2D = preload(
	"res://assets/sprites/units/mage_prototype.png"
)
const ELF: Texture2D = preload(
	"res://assets/sprites/units/elf_prototype.png"
)
const FOREMAN: Texture2D = preload(
	"res://assets/sprites/units/foreman_prototype.png"
)
const GRAVE_MARSHAL: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_prototype.png"
)
const ARCANE_AUDITOR: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_prototype.png"
)
const LICH: Texture2D = preload(
	"res://assets/sprites/units/lich_prototype.png"
)

const SKELETON_ANIMATIONS: Dictionary = {
	"idle": SKELETON_IDLE,
	"move": SKELETON_MOVE,
	"attack": SKELETON_ATTACK,
	"hit": SKELETON_HIT,
	"death": SKELETON_DEATH,
}


static func get_texture(visual_id: String) -> Texture2D:

	match visual_id:
		"skeleton":
			return SKELETON
		"skeleton_archer":
			return SKELETON_ARCHER
		"zombie":
			return ZOMBIE
		"mage":
			return MAGE
		"elf":
			return ELF
		"foreman":
			return FOREMAN
		"grave_marshal":
			return GRAVE_MARSHAL
		"arcane_auditor":
			return ARCANE_AUDITOR
		"lich":
			return LICH
		_:
			return HUMAN_WARRIOR


static func get_animation_textures(visual_id: String) -> Dictionary:
	if visual_id == "skeleton":
		return SKELETON_ANIMATIONS.duplicate()
	return {}


static func get_canvas_scale_multiplier(visual_id: String) -> float:
	# The final Skeleton sources keep a generous transparent safe area.
	return 1.34 if visual_id == "skeleton" else 1.0
