extends RefCounted


static func create(max_units: int, accent_color: Color) -> Dictionary:
	var zombie_button: Button = Button.new()
	zombie_button.name = "CreateZombieButton"
	zombie_button.text = "CREATE ZOMBIE"

	var archer_button: Button = Button.new()
	archer_button.name = "CreateSkeletonArcherButton"
	archer_button.text = "SKELETON ARCHER LOCKED"

	var quantity_selector: SpinBox = SpinBox.new()
	quantity_selector.name = "ProductionQuantitySelector"
	quantity_selector.min_value = 1.0
	quantity_selector.max_value = float(max_units)
	quantity_selector.step = 1.0
	quantity_selector.value = 1.0
	quantity_selector.allow_greater = false
	quantity_selector.allow_lesser = false
	quantity_selector.update_on_text_changed = true
	quantity_selector.z_index = 110
	quantity_selector.add_theme_font_size_override("font_size", 16)

	var queue_label: Label = Label.new()
	queue_label.name = "ProductionQueueLabel"
	queue_label.position = Vector2(390.0, 988.0)
	queue_label.size = Vector2(650.0, 18.0)
	queue_label.z_index = 110
	queue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	queue_label.add_theme_font_size_override("font_size", 12)
	queue_label.add_theme_color_override("font_color", accent_color)

	return {
		"zombie_button": zombie_button,
		"archer_button": archer_button,
		"quantity_selector": quantity_selector,
		"queue_label": queue_label,
	}
