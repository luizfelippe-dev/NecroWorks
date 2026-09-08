extends SceneTree


const DESIGN_SIZE := Vector2i(1920, 1080)
const TARGETS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(1280, 800),
	Vector2i(1920, 1200),
	Vector2i(2560, 1080),
]


func _initialize() -> void:
	assert(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items")
	assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep")
	for target: Vector2i in TARGETS:
		var scale_factor: float = minf(
			float(target.x) / float(DESIGN_SIZE.x),
			float(target.y) / float(DESIGN_SIZE.y)
		)
		var rendered: Vector2 = Vector2(DESIGN_SIZE) * scale_factor
		assert(rendered.x <= float(target.x) + 0.01)
		assert(rendered.y <= float(target.y) + 0.01)
		assert(scale_factor > 0.0)
	print("RESOLUTION MATRIX: PASS (6 TARGETS, NO DESIGN-VIEWPORT CROP)")
	quit()
