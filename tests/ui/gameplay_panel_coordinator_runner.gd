extends SceneTree


const GameplayPanelCoordinator: Script = preload(
	"res://scripts/ui/gameplay_panel_coordinator.gd"
)


func _initialize() -> void:
	var coordinator: RefCounted = GameplayPanelCoordinator.new()
	var factory := Control.new()
	var ritual := Control.new()
	var upgrade := Control.new()
	root.add_child(factory)
	root.add_child(ritual)
	root.add_child(upgrade)
	coordinator.register("factory", factory)
	coordinator.register("ritual", ritual)
	coordinator.register("upgrade", upgrade)
	coordinator.close_all()
	assert(coordinator.toggle_exclusive("factory"))
	assert(factory.visible and not ritual.visible)
	assert(coordinator.toggle_exclusive("ritual"))
	assert(ritual.visible and not factory.visible)
	coordinator.show_exclusive("upgrade")
	assert(upgrade.visible and not ritual.visible)
	assert(not coordinator.toggle_exclusive("factory", PackedStringArray(["upgrade"])))
	assert(not factory.visible and upgrade.visible)
	print("GAMEPLAY PANEL COORDINATOR VALIDATION: PASS")
	quit()
