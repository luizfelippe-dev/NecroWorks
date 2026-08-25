extends SceneTree


const FACTORY: Script = preload("res://scripts/ui/production_controls_factory.gd")


func _initialize() -> void:
	var controls: Dictionary = FACTORY.create(36, Color.GREEN)
	var selector: SpinBox = controls["quantity_selector"] as SpinBox
	assert((controls["zombie_button"] as Button).name == "CreateZombieButton")
	assert((controls["archer_button"] as Button).name == "CreateSkeletonArcherButton")
	assert(selector.min_value == 1.0)
	assert(selector.max_value == 36.0)
	assert((controls["queue_label"] as Label).z_index == 110)
	for control: Control in controls.values():
		control.free()
	print("PRODUCTION CONTROLS FACTORY VALIDATION: PASS")
	quit()
