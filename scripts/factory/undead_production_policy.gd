class_name UndeadProductionPolicy
extends RefCounted


static func get_queued_unit_count(queue: Array[Dictionary]) -> int:

	var total: int = 0


	for order: Dictionary in queue:
		total += maxi(int(order.get("remaining", 0)), 0)


	return total


static func can_enqueue_order(
	quantity: int,
	unit_cost: int,
	available_resource: int,
	current_army: int,
	queued_units: int,
	maximum_army: int,
	current_orders: int,
	maximum_orders: int
) -> bool:

	if quantity < 1 or unit_cost < 0:
		return false


	if current_orders >= maximum_orders:
		return false


	if current_army + queued_units + quantity > maximum_army:
		return false


	return available_resource >= quantity * unit_cost


static func create_order(quantity: int, unit_cost: int) -> Dictionary:

	return {
		"quantity": quantity,
		"remaining": quantity,
		"unit_cost": unit_cost,
		"total_cost": quantity * unit_cost
	}
