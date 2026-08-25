extends RefCounted


const FORMATION_COLUMNS: int = 6
const FORMATION_ROWS: int = 6
const MAX_UNDEAD: int = FORMATION_COLUMNS * FORMATION_ROWS

const SPAWN_SPACING: Vector2 = Vector2(85.0, 85.0)
const SPAWN_ORIGIN: Vector2 = Vector2(250.0, 350.0)

const COMBAT_ROWS: int = 6
const COMBAT_SPACING_X: float = 85.0
const COMBAT_SPACING_Y: float = 85.0
const COMBAT_FRONT_DISTANCE: float = 110.0
const COMBAT_ROW_ORDER: Array[int] = [2, 3, 1, 4, 0, 5]

const ENEMY_LANE_Y: float = 555.0
const COMBAT_MIN_X: float = 80.0
const COMBAT_MAX_X: float = 1500.0
const COMBAT_MIN_Y: float = 300.0
const COMBAT_MAX_Y: float = 810.0


static func get_spawn_position(slot: int) -> Vector2:
	var safe_slot: int = maxi(slot, 0)
	var column: int = safe_slot % FORMATION_COLUMNS
	var row: int = int(safe_slot / FORMATION_COLUMNS)
	return SPAWN_ORIGIN + Vector2(
		float(column) * SPAWN_SPACING.x,
		float(row) * SPAWN_SPACING.y
	)


static func get_combat_position(
	enemy_position: Vector2,
	compacted_slot: int
) -> Vector2:
	var safe_slot: int = maxi(compacted_slot, 0)
	var combat_column: int = int(safe_slot / COMBAT_ROWS)
	var slot_inside_column: int = safe_slot % COMBAT_ROWS
	var row_index: int = COMBAT_ROW_ORDER[slot_inside_column]
	var vertical_offset: float = (float(row_index) - 2.5) * COMBAT_SPACING_Y
	var horizontal_offset: float = (
		COMBAT_FRONT_DISTANCE + float(combat_column) * COMBAT_SPACING_X
	)
	return Vector2(
		clampf(enemy_position.x - horizontal_offset, COMBAT_MIN_X, COMBAT_MAX_X),
		clampf(ENEMY_LANE_Y + vertical_offset, COMBAT_MIN_Y, COMBAT_MAX_Y)
	)


static func get_ranged_combat_position(
	target_enemy_position: Vector2,
	attack_range: float,
	formation_position: Vector2
) -> Vector2:
	return Vector2(
		clampf(
			target_enemy_position.x - maxf(attack_range, 0.0),
			COMBAT_MIN_X,
			COMBAT_MAX_X
		),
		formation_position.y
	)


static func get_compacted_slot(original_slot: int, ordered_slots: Array[int]) -> int:
	var compacted_index: int = ordered_slots.find(original_slot)
	return compacted_index if compacted_index >= 0 else original_slot
