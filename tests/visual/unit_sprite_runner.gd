extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const VISUAL_IDS: Array[String] = [
	"skeleton",
	"zombie",
	"human_warrior",
	"mage",
	"elf",
	"foreman"
]


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	assert(game.initial_skeleton.get_node_or_null("UnitSprite") is Sprite2D)
	assert(game.initial_enemy.get_node_or_null("UnitSprite") is Sprite2D)
	assert(game.initial_skeleton.get_node_or_null("DebugVisual") == null)
	assert(game.initial_enemy.get_node_or_null("DebugVisual") == null)


	for visual_id: String in VISUAL_IDS:
		var unit: Node2D = Node2D.new()
		game.add_child(unit)
		game.ensure_unit_visual(unit, Color.WHITE, visual_id)
		var sprite: Sprite2D = unit.get_node_or_null("UnitSprite") as Sprite2D
		assert(sprite != null)
		assert(sprite.texture != null)
		assert(sprite.texture.get_width() > 0)
		assert(sprite.texture.get_height() > 0)
		assert(sprite.texture.get_width() <= 512)
		assert(sprite.texture.get_height() <= 512)
		assert(sprite.scale.x > 0.0)
		assert(is_equal_approx(sprite.scale.x, sprite.scale.y))
		unit.queue_free()


	print("UNIT SPRITE VALIDATION: PASS")
	game.queue_free()
	quit()
