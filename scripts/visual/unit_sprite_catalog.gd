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
const SKELETON_ARCHER_IDLE: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_v1/idle.png"
)
const SKELETON_ARCHER_MOVE: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_v1/move.png"
)
const SKELETON_ARCHER_ATTACK: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_v1/attack.png"
)
const SKELETON_ARCHER_HIT: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_v1/hit.png"
)
const SKELETON_ARCHER_DEATH: Texture2D = preload(
	"res://assets/sprites/units/skeleton_archer_v1/death.png"
)
const SKELETON_ARCHER: Texture2D = SKELETON_ARCHER_IDLE
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
const FOREMAN_IDLE: Texture2D = preload(
	"res://assets/sprites/bosses/foreman_v1/idle.png"
)
const FOREMAN_MOVE: Texture2D = preload(
	"res://assets/sprites/bosses/foreman_v1/move.png"
)
const FOREMAN_ATTACK: Texture2D = preload(
	"res://assets/sprites/bosses/foreman_v1/attack.png"
)
const FOREMAN_HIT: Texture2D = preload(
	"res://assets/sprites/bosses/foreman_v1/hit.png"
)
const FOREMAN_DEATH: Texture2D = preload(
	"res://assets/sprites/bosses/foreman_v1/death.png"
)
const FOREMAN: Texture2D = FOREMAN_IDLE
const GRAVE_MARSHAL_IDLE: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_v1/idle.png"
)
const GRAVE_MARSHAL_MOVE: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_v1/move.png"
)
const GRAVE_MARSHAL_ATTACK: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_v1/attack.png"
)
const GRAVE_MARSHAL_HIT: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_v1/hit.png"
)
const GRAVE_MARSHAL_DEATH: Texture2D = preload(
	"res://assets/sprites/bosses/grave_marshal_v1/death.png"
)
const GRAVE_MARSHAL: Texture2D = GRAVE_MARSHAL_IDLE
const ARCANE_AUDITOR_IDLE: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_v1/idle.png"
)
const ARCANE_AUDITOR_MOVE: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_v1/move.png"
)
const ARCANE_AUDITOR_ATTACK: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_v1/attack.png"
)
const ARCANE_AUDITOR_HIT: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_v1/hit.png"
)
const ARCANE_AUDITOR_DEATH: Texture2D = preload(
	"res://assets/sprites/bosses/arcane_auditor_v1/death.png"
)
const ARCANE_AUDITOR: Texture2D = ARCANE_AUDITOR_IDLE
const LICH_IDLE: Texture2D = preload("res://assets/sprites/units/lich_v1/idle.png")
const LICH_MOVE: Texture2D = preload("res://assets/sprites/units/lich_v1/move.png")
const LICH_ATTACK: Texture2D = preload("res://assets/sprites/units/lich_v1/attack.png")
const LICH_HIT: Texture2D = preload("res://assets/sprites/units/lich_v1/hit.png")
const LICH_DEATH: Texture2D = preload("res://assets/sprites/units/lich_v1/death.png")
const LICH: Texture2D = LICH_IDLE

const SKELETON_ANIMATIONS: Dictionary = {
	"idle": SKELETON_IDLE,
	"move": SKELETON_MOVE,
	"attack": SKELETON_ATTACK,
	"hit": SKELETON_HIT,
	"death": SKELETON_DEATH,
}
const SKELETON_ARCHER_ANIMATIONS: Dictionary = {
	"idle": SKELETON_ARCHER_IDLE,
	"move": SKELETON_ARCHER_MOVE,
	"attack": SKELETON_ARCHER_ATTACK,
	"hit": SKELETON_ARCHER_HIT,
	"death": SKELETON_ARCHER_DEATH,
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
const GRAVE_MARSHAL_ANIMATIONS: Dictionary = {
	"idle": GRAVE_MARSHAL_IDLE,
	"move": GRAVE_MARSHAL_MOVE,
	"attack": GRAVE_MARSHAL_ATTACK,
	"hit": GRAVE_MARSHAL_HIT,
	"death": GRAVE_MARSHAL_DEATH,
}
const ARCANE_AUDITOR_ANIMATIONS: Dictionary = {
	"idle": ARCANE_AUDITOR_IDLE,
	"move": ARCANE_AUDITOR_MOVE,
	"attack": ARCANE_AUDITOR_ATTACK,
	"hit": ARCANE_AUDITOR_HIT,
	"death": ARCANE_AUDITOR_DEATH,
}
const FOREMAN_ANIMATIONS: Dictionary = {
	"idle": FOREMAN_IDLE,
	"move": FOREMAN_MOVE,
	"attack": FOREMAN_ATTACK,
	"hit": FOREMAN_HIT,
	"death": FOREMAN_DEATH,
}
const LICH_ANIMATIONS: Dictionary = {
	"idle": LICH_IDLE,
	"move": LICH_MOVE,
	"attack": LICH_ATTACK,
	"hit": LICH_HIT,
	"death": LICH_DEATH,
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
	if visual_id == "skeleton_archer":
		return SKELETON_ARCHER_ANIMATIONS.duplicate()
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
	if visual_id == "grave_marshal":
		return GRAVE_MARSHAL_ANIMATIONS.duplicate()
	if visual_id == "arcane_auditor":
		return ARCANE_AUDITOR_ANIMATIONS.duplicate()
	if visual_id == "foreman":
		return FOREMAN_ANIMATIONS.duplicate()
	if visual_id == "lich":
		return LICH_ANIMATIONS.duplicate()
	return {}


static var skeleton_sequences: Dictionary = {}

static func get_animation_sequences(visual_id: String) -> Dictionary:
	if visual_id != "skeleton":
		return {}
	if skeleton_sequences.is_empty():
		var walk: Texture2D = load("res://assets/sprites/units/skeleton_warrior_v2/walk_sheet.png")
		var recovery: Texture2D = load("res://assets/sprites/units/skeleton_warrior_v2/recovery_sheet.png")
		var walk_frames: Array[Texture2D] = []
		for index: int in range(8):
			walk_frames.append(sheet_frame(walk, index))
		# Impact remains synchronous with damage. Only isolated recovery cells are used.
		skeleton_sequences = {"move": walk_frames, "attack": [SKELETON_ATTACK,
			sheet_frame(recovery, 5), sheet_frame(recovery, 6), sheet_frame(recovery, 7)]}
	return skeleton_sequences.duplicate(true)

static func sheet_frame(sheet: Texture2D, index: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = sheet
	var cell := sheet.get_size() / Vector2(4, 2)
	var origin := Vector2(index % 4, index / 4) * cell
	# Generated poses slightly cross nominal columns. Shift within transparent gutters.
	var gutter: float = 16.0 * sheet.get_width() / 1776.0
	origin.x += gutter
	var width: float = minf(cell.x, sheet.get_width() - origin.x)
	frame.region = Rect2(origin, Vector2(width, cell.y))
	frame.margin = Rect2(0, 0, cell.x - width, 0)
	frame.filter_clip = true
	return frame


static func get_motion_profile(visual_id: String) -> Dictionary:
	var enemies := ["human_warrior", "mage", "elf", "grave_marshal", "arcane_auditor", "foreman"]
	var profile := {
		"facing": -1.0 if visual_id in enemies else 1.0,
		"walk_period": 0.56, "attack_duration": 0.32, "stride": 0.045,
		"bob": 1.15, "attack_travel": 6.0, "spectral": 0.0,
	}
	if visual_id in ["zombie", "grave_marshal", "foreman"]:
		profile.merge({"walk_period": 0.76, "stride": 0.033, "bob": 0.8, "attack_duration": 0.38, "attack_travel": 5.0}, true)
	elif visual_id in ["elf", "skeleton_archer"]:
		profile.merge({"walk_period": 0.48, "attack_duration": 0.30, "attack_travel": 2.0}, true)
	elif visual_id in ["mage", "lich", "arcane_auditor"]:
		profile.merge({"walk_period": 0.66, "stride": 0.021, "attack_duration": 0.36, "attack_travel": 2.0}, true)
	elif visual_id == "ghost":
		profile.merge({"walk_period": 0.85, "spectral": 1.0, "bob": 2.0, "attack_travel": 3.0}, true)
	# Image-space leg anchors exclude weapons, capes and nearly transparent halos.
	var leg_anchors := {
		"skeleton": Vector2(0.42, 0.55), "skeleton_archer": Vector2(0.40, 0.57),
		"zombie": Vector2(0.45, 0.58), "human_warrior": Vector2(0.54, 0.58),
		"elf": Vector2(0.53, 0.60), "mage": Vector2(0.59, 0.60),
		"lich": Vector2(0.53, 0.67), "grave_marshal": Vector2(0.51, 0.75),
		"arcane_auditor": Vector2(0.50, 0.65), "foreman": Vector2(0.53, 0.65),
	}
	var anchor: Vector2 = leg_anchors.get(visual_id, Vector2(0.5, 0.6))
	profile["leg_split"] = anchor.x
	profile["leg_root"] = anchor.y
	return profile


static func get_canvas_scale_multiplier(visual_id: String) -> float:
	# Final state sources keep transparent safe areas around their silhouettes.
	match visual_id:
		"skeleton":
			return 1.34
		"skeleton_archer":
			return 1.20
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
		"grave_marshal":
			return 1.08
		"arcane_auditor":
			return 1.08
		"foreman":
			return 1.08
		"lich":
			return 1.12
		_:
			return 1.0
