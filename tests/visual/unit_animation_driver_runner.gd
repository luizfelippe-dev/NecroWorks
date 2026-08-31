extends SceneTree


const DRIVER_SCRIPT: Script = preload(
	"res://scripts/visual/unit_animation_driver.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var host: Node2D = Node2D.new()
	var sprite: Sprite2D = Sprite2D.new()
	var driver: Node = DRIVER_SCRIPT.new()
	root.add_child(host)
	host.add_child(sprite)
	host.add_child(driver)
	driver.call("bind", sprite)
	assert(driver.call("play", "attack", -1.0))
	assert(str(driver.get("current_animation")) == "attack")
	await create_timer(0.25).timeout
	assert(str(driver.get("current_animation")) == "idle")
	assert(driver.call("play", "hit"))
	await create_timer(0.2).timeout
	assert(str(driver.get("current_animation")) == "idle")
	assert(not driver.call("play", "unsupported"))
	host.free()
	print("UNIT ANIMATION CONTRACT VALIDATION: PASS")
	quit()
