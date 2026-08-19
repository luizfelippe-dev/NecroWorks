extends RefCounted


const SKELETON: Texture2D = preload(
	"res://assets/sprites/units/skeleton_prototype.png"
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


static func get_texture(visual_id: String) -> Texture2D:

	match visual_id:
		"skeleton":
			return SKELETON
		"zombie":
			return ZOMBIE
		"mage":
			return MAGE
		"elf":
			return ELF
		"foreman":
			return FOREMAN
		_:
			return HUMAN_WARRIOR
