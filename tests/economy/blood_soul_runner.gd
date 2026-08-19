extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	game.total_enemies_killed = 8
	assert(
		game.apply_necromantic_kill_rewards(
			"human_warrior", false, false
		) == Vector2i(1, 0)
	)
	game.total_enemies_killed = 9
	assert(
		game.apply_necromantic_kill_rewards(
			"mage", false, false
		) == Vector2i(0, 1)
	)
	assert(game.blood == 1)
	assert(game.souls == 1)


	game.blood = 10
	assert(game.purchase_blood_extraction_upgrade())
	assert(game.purchase_blood_infusion_upgrade())
	assert(game.has_synergy(game.SYNERGY_CRIMSON_ASSEMBLY))
	assert(game.get_blood_sacrifice_cost() == 2)
	var blood_before_fervor: int = game.blood
	assert(game.activate_blood_fervor())
	assert(game.blood == blood_before_fervor - 2)
	assert(game.get_modified_undead_damage(10) == 14)


	game.souls = 10
	assert(game.purchase_soul_focus_upgrade())
	assert(game.purchase_soul_anchor_upgrade())
	assert(game.has_synergy(game.SYNERGY_PHANTOM_CONDUIT))
	game.souls = game.ghost_cost
	var enemy_hp_before: int = int(game.enemy_hps[game.initial_enemy])
	assert(game.create_ghost())
	assert(game.ghosts.size() == 1)
	assert(game.souls == 0)
	var ghost: Node2D = game.ghosts[0]
	assert(int(ghost.get("damage")) == 20)
	assert(int(ghost.get("maximum_hp")) == 95)
	assert(float(ghost.get("attack_cooldown")) == 1.20)
	game.ghost_attack_enemy(ghost)
	assert(int(game.enemy_hps[game.initial_enemy]) < enemy_hp_before)
	assert(float(ghost.get("attack_timer")) > 0.0)
	game.damage_undead(ghost, 9999, "TEST")
	assert(game.ghosts.is_empty())
	assert(game.total_ghosts_lost == 1)


	game.blood = 8
	game.souls = 4
	game.update_bones_ui()
	game.toggle_ritual_panel()
	assert(game.ritual_panel.visible)
	assert(game.ritual_nav_button.text.length() > 0)
	assert(game.ritual_status_label.text.contains("8"))


	for _frame: int in range(30):
		await process_frame


	print("BLOOD / SOUL / GHOST VALIDATION: PASS")
	game.queue_free()
	quit()
