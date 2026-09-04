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
const ZOMBIE_IDLE: Texture2D = preload(
	"res://assets/sprites/units/zombie_tank_v1/idle.png"
)
const ZOMBIE_MOVE: Texture2D = preload(
	"res://assets/sprites/units/zombie_tank_v1/move.png"
)
const ZOMBIE_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/zombie_tank_v1/attack.png"
)
const ZOMBIE_HIT: Texture2D = preload(
	"res://assets/sprites/units/zombie_tank_v1/hit.png"
)
const ZOMBIE_DEATH: Texture2D = preload(
	"res://assets/sprites/units/zombie_tank_v1/death.png"
)
const ZOMBIE: Texture2D = ZOMBIE_IDLE
const GHOST_IDLE: Texture2D = preload(
	"res://assets/sprites/units/ghost_v1/idle.png"
)
const GHOST_MOVE: Texture2D = preload(
	"res://assets/sprites/units/ghost_v1/move.png"
)
const GHOST_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/ghost_v1/attack.png"
)
const GHOST_HIT: Texture2D = preload(
	"res://assets/sprites/units/ghost_v1/hit.png"
)
const GHOST_DEATH: Texture2D = preload(
	"res://assets/sprites/units/ghost_v1/death.png"
)
const GHOST: Texture2D = GHOST_IDLE
const HUMAN_WARRIOR_IDLE: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_v1/idle.png"
)
const HUMAN_WARRIOR_MOVE: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_v1/move.png"
)
const HUMAN_WARRIOR_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_v1/attack.png"
)
const HUMAN_WARRIOR_HIT: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_v1/hit.png"
)
const HUMAN_WARRIOR_DEATH: Texture2D = preload(
	"res://assets/sprites/units/human_warrior_v1/death.png"
)
const HUMAN_WARRIOR: Texture2D = HUMAN_WARRIOR_IDLE
const MAGE_IDLE: Texture2D = preload(
	"res://assets/sprites/units/mage_v1/idle.png"
)
const MAGE_MOVE: Texture2D = preload(
	"res://assets/sprites/units/mage_v1/move.png"
)
const MAGE_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/mage_v1/attack.png"
)
const MAGE_HIT: Texture2D = preload(
	"res://assets/sprites/units/mage_v1/hit.png"
)
const MAGE_DEATH: Texture2D = preload(
	"res://assets/sprites/units/mage_v1/death.png"
)
const MAGE: Texture2D = MAGE_IDLE
const ELF_IDLE: Texture2D = preload(
	"res://assets/sprites/units/elf_v1/idle.png"
)
const ELF_MOVE: Texture2D = preload(
	"res://assets/sprites/units/elf_v1/move.png"
)
const ELF_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/elf_v1/attack.png"
)
const ELF_HIT: Texture2D = preload(
	"res://assets/sprites/units/elf_v1/hit.png"
)
const ELF_DEATH: Texture2D = preload(
	"res://assets/sprites/units/elf_v1/death.png"
)
const ELF: Texture2D = ELF_IDLE
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
const ZOMBIE_ANIMATIONS: Dictionary = {
	"idle": ZOMBIE_IDLE,
	"move": ZOMBIE_MOVE,
	"attack": ZOMBIE_ATTACK,
	"hit": ZOMBIE_HIT,
	"death": ZOMBIE_DEATH,
}
const GHOST_ANIMATIONS: Dictionary = {
	"idle": GHOST_IDLE,
	"move": GHOST_MOVE,
	"attack": GHOST_ATTACK,
	"hit": GHOST_HIT,
	"death": GHOST_DEATH,
}
const HUMAN_WARRIOR_ANIMATIONS: Dictionary = {
	"idle": HUMAN_WARRIOR_IDLE,
	"move": HUMAN_WARRIOR_MOVE,
	"attack": HUMAN_WARRIOR_ATTACK,
	"hit": HUMAN_WARRIOR_HIT,
	"death": HUMAN_WARRIOR_DEATH,
}
const MAGE_ANIMATIONS: Dictionary = {
	"idle": MAGE_IDLE,
	"move": MAGE_MOVE,
	"attack": MAGE_ATTACK,
	"hit": MAGE_HIT,
	"death": MAGE_DEATH,
}
const ELF_ANIMATIONS: Dictionary = {
	"idle": ELF_IDLE,
	"move": ELF_MOVE,
	"attack": ELF_ATTACK,
	"hit": ELF_HIT,
	"death": ELF_DEATH,
}


static func get_texture(visual_id: String) -> Texture2D:

	match visual_id:
		"skeleton":
			return SKELETON
		"skeleton_archer":
			return SKELETON_ARCHER
		"zombie":
			return ZOMBIE
		"ghost":
			return GHOST
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
	if visual_id == "zombie":
		return ZOMBIE_ANIMATIONS.duplicate()
	if visual_id == "ghost":
		return GHOST_ANIMATIONS.duplicate()
	if visual_id == "human_warrior":
		return HUMAN_WARRIOR_ANIMATIONS.duplicate()
	if visual_id == "mage":
		return MAGE_ANIMATIONS.duplicate()
	if visual_id == "elf":
		return ELF_ANIMATIONS.duplicate()
	return {}


static func get_canvas_scale_multiplier(visual_id: String) -> float:
	# Final state sources keep transparent safe areas around their silhouettes.
	match visual_id:
		"skeleton":
			return 1.34
		"zombie":
			return 1.14
		"ghost":
			return 1.07
		"human_warrior":
			return 1.22
		"mage":
			return 1.20
		"elf":
			return 1.10
		_:
			return 1.0
