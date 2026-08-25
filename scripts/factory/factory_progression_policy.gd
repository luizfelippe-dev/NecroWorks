extends RefCounted


const PROCESSOR_BASE_CAPACITY: int = 5
const PROCESSOR_BASE_SECONDS: float = 0.65
const AUTO_COLLECTION_COST: int = 2
const AUTO_COLLECTION_SCAN_INTERVAL: float = 0.25
const PROCESSOR_UPGRADE_MAX_LEVEL: int = 3
const QUEUE_UPGRADE_BASE_COST: int = 1
const QUEUE_CAPACITY_PER_LEVEL: int = 2
const SPEED_UPGRADE_BASE_COST: int = 1
const PROCESSING_SECONDS_REDUCTION: float = 0.10
const EFFICIENCY_BASE_COST: int = 2
const EFFICIENCY_MAX_LEVEL: int = 3
const EFFICIENCY_FLESH_REDUCTION: int = 2
const EFFICIENCY_SOUL_SECONDS_REDUCTION: float = 0.25


static func get_queue_upgrade_cost(level: int) -> int:
	return QUEUE_UPGRADE_BASE_COST + clampi(level, 0, PROCESSOR_UPGRADE_MAX_LEVEL)


static func get_speed_upgrade_cost(level: int) -> int:
	return SPEED_UPGRADE_BASE_COST + clampi(level, 0, PROCESSOR_UPGRADE_MAX_LEVEL)


static func get_efficiency_upgrade_cost(level: int) -> int:
	return EFFICIENCY_BASE_COST + clampi(level, 0, EFFICIENCY_MAX_LEVEL)


static func get_processor_capacity(queue_level: int) -> int:
	return PROCESSOR_BASE_CAPACITY + max(queue_level, 0) * QUEUE_CAPACITY_PER_LEVEL


static func get_processor_cycle_seconds(speed_level: int) -> float:
	return maxf(
		PROCESSOR_BASE_SECONDS
		- max(speed_level, 0) * PROCESSING_SECONDS_REDUCTION,
		0.1
	)


static func get_hematic_flesh_cost(
	base_cost: int, efficiency_level: int, dark_refinery_active: bool
) -> int:
	return maxi(
		base_cost
		- max(efficiency_level, 0) * EFFICIENCY_FLESH_REDUCTION
		- (2 if dark_refinery_active else 0),
		4
	)


static func get_soul_extractor_cycle_seconds(
	base_seconds: float, efficiency_level: int
) -> float:
	return maxf(
		base_seconds
		- max(efficiency_level, 0) * EFFICIENCY_SOUL_SECONDS_REDUCTION,
		1.0
	)
