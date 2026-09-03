extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const VISUAL_IDS: Array[String] = [
	"skeleton",
	"skeleton_archer",
	"zombie",
	"ghost",
	"human_warrior",
	"mage",
	"elf",
	"grave_marshal",
	"arcane_auditor",
	"foreman",
	"lich"
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
		var driver: Node = unit.get_node_or_null("AnimationDriver")
		assert(driver != null)
		var state_textures: Dictionary = driver.get("state_textures") as Dictionary
		if visual_id in ["skeleton", "zombie", "ghost"]:
			assert(state_textures.size() == 5)
			assert(sprite.texture == state_textures["idle"])
			assert(sprite.scale.x > 0.20)
			game.play_unit_move_animation(unit, 1.0)
			assert(sprite.texture == state_textures["move"])
			await create_timer(0.25).timeout
			assert(sprite.texture == state_textures["idle"])
			game.play_unit_animation(unit, "attack", 1.0)
			assert(sprite.texture == state_textures["attack"])
			await create_timer(0.25).timeout
			game.play_unit_animation(unit, "hit")
			assert(sprite.texture == state_textures["hit"])
			await create_timer(0.20).timeout
			game.play_unit_animation(unit, "death")
			assert(sprite.texture == state_textures["death"])
		else:
			assert(state_textures.is_empty())
		unit.queue_free()

	assert(game.create_free_zombie("VISUAL_TEST"))
	var retiring_zombie: Node2D = game.zombies.back() as Node2D
	var retiring_driver: Node = retiring_zombie.get_node("AnimationDriver")
	game.kill_zombie(retiring_zombie)
	assert(not game.zombies.has(retiring_zombie))
	assert(is_instance_valid(retiring_zombie))
	assert(str(retiring_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_zombie))

	assert(game.create_free_ghost())
	var retiring_ghost: Node2D = game.ghosts.back() as Node2D
	var ghost_driver: Node = retiring_ghost.get_node("AnimationDriver")
	game.kill_ghost(retiring_ghost)
	assert(not game.ghosts.has(retiring_ghost))
	assert(is_instance_valid(retiring_ghost))
	assert(str(ghost_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_ghost))


	print("UNIT SPRITE VALIDATION: PASS")
	game.queue_free()
	quit()
