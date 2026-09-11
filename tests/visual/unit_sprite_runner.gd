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
		assert(unit.get_node_or_null("FrameBlend") == null)
		assert(sprite.material is ShaderMaterial)
		assert(not (driver.get("profile") as Dictionary).is_empty())
		var state_textures: Dictionary = driver.get("state_textures") as Dictionary
		var frame_sequences: Dictionary = driver.get("frame_sequences") as Dictionary
		if visual_id in [
			"skeleton", "skeleton_archer", "zombie", "ghost", "lich",
			"human_warrior", "mage", "elf", "grave_marshal",
			"arcane_auditor", "foreman"
		]:
			assert(state_textures.size() == 5)
			assert(frame_sequences.is_empty())
			assert(sprite.texture == state_textures["idle"])
			assert(sprite.scale.x > 0.20)
			game.play_unit_move_animation(unit, 1.0)
			assert(sprite.texture == state_textures["move"])
			await create_timer(0.50).timeout
			assert(sprite.texture == state_textures["idle"])
			game.play_unit_animation(unit, "attack", 1.0)
			assert(str(driver.get("current_animation")) == "attack")
			await create_timer(0.11).timeout
			assert(sprite.texture == state_textures["attack"])
			await create_timer(0.35).timeout
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

	var retiring_enemy: Node2D = game.initial_enemy
	var enemy_driver: Node = retiring_enemy.get_node("AnimationDriver")
	game.kill_enemy(retiring_enemy)
	assert(not game.enemies.has(retiring_enemy))
	assert(is_instance_valid(retiring_enemy))
	assert(str(enemy_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_enemy))

	var retiring_mage: Node2D = Node2D.new()
	game.add_child(retiring_mage)
	game.ensure_unit_visual(retiring_mage, Color(0.33, 0.30, 0.82), "mage")
	game.enemies.append(retiring_mage)
	game.enemy_types[retiring_mage] = "mage"
	game.enemy_elite_flags[retiring_mage] = false
	var mage_driver: Node = retiring_mage.get_node("AnimationDriver")
	game.kill_enemy(retiring_mage)
	assert(not game.enemies.has(retiring_mage))
	assert(is_instance_valid(retiring_mage))
	assert(str(mage_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_mage))

	var retiring_elf: Node2D = Node2D.new()
	game.add_child(retiring_elf)
	game.ensure_unit_visual(retiring_elf, Color(0.28, 0.55, 0.22), "elf")
	game.enemies.append(retiring_elf)
	game.enemy_types[retiring_elf] = "elf"
	game.enemy_elite_flags[retiring_elf] = false
	var elf_driver: Node = retiring_elf.get_node("AnimationDriver")
	game.kill_enemy(retiring_elf)
	assert(not game.enemies.has(retiring_elf))
	assert(is_instance_valid(retiring_elf))
	assert(str(elf_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_elf))

	var retiring_marshal: Node2D = Node2D.new()
	game.add_child(retiring_marshal)
	game.ensure_unit_visual(
		retiring_marshal, Color(0.42, 0.28, 0.12), "grave_marshal"
	)
	game.enemies.append(retiring_marshal)
	game.enemy_types[retiring_marshal] = "grave_marshal"
	game.enemy_elite_flags[retiring_marshal] = false
	var marshal_driver: Node = retiring_marshal.get_node("AnimationDriver")
	game.kill_enemy(retiring_marshal)
	assert(not game.enemies.has(retiring_marshal))
	assert(is_instance_valid(retiring_marshal))
	assert(str(marshal_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_marshal))

	var retiring_auditor: Node2D = Node2D.new()
	game.add_child(retiring_auditor)
	game.ensure_unit_visual(
		retiring_auditor, Color(0.38, 0.18, 0.62), "arcane_auditor"
	)
	game.enemies.append(retiring_auditor)
	game.enemy_types[retiring_auditor] = "arcane_auditor"
	game.enemy_elite_flags[retiring_auditor] = false
	var auditor_driver: Node = retiring_auditor.get_node("AnimationDriver")
	game.kill_enemy(retiring_auditor)
	assert(not game.enemies.has(retiring_auditor))
	assert(is_instance_valid(retiring_auditor))
	assert(str(auditor_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_auditor))

	var retiring_foreman: Node2D = Node2D.new()
	game.add_child(retiring_foreman)
	game.ensure_unit_visual(
		retiring_foreman, Color(0.48, 0.26, 0.10), "foreman"
	)
	game.enemies.append(retiring_foreman)
	game.enemy_types[retiring_foreman] = "foreman"
	game.enemy_elite_flags[retiring_foreman] = false
	var foreman_driver: Node = retiring_foreman.get_node("AnimationDriver")
	game.kill_enemy(retiring_foreman)
	assert(not game.enemies.has(retiring_foreman))
	assert(is_instance_valid(retiring_foreman))
	assert(str(foreman_driver.get("current_animation")) == "death")
	await create_timer(0.30).timeout
	await process_frame
	assert(not is_instance_valid(retiring_foreman))


	print("UNIT SPRITE VALIDATION: PASS")
	game.queue_free()
	quit()
