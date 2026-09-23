extends SceneTree


const FEEDBACK_SCRIPT: Script = preload("res://scripts/visual/combat_feedback.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var feedback: Node2D = FEEDBACK_SCRIPT.new() as Node2D
	root.add_child(feedback)
	feedback.call("set_accessibility", false, true)
	feedback.call("show_damage", Vector2(400.0, 400.0), 17, true, true)
	feedback.call(
		"show_attack_trace",
		Vector2(300.0, 400.0),
		Vector2(500.0, 400.0),
		Color.GREEN
	)
	feedback.call("show_impact", Vector2(500.0, 400.0), Color.PURPLE, 50.0, true)
	feedback.call("show_boss_banner", "BOSS SIGNAL", Color.PURPLE)
	assert(feedback.get_child_count() == 4)
	assert(int(feedback.get("feedback_created")) == 4)
	var damage_label: Label = feedback.get_node("DamageNumber") as Label
	assert(damage_label.text == "-17")
	assert(damage_label.get_theme_constant("outline_size") == 6)
	await create_timer(0.55).timeout
	assert(feedback.get_child_count() == 1)
	assert(feedback.has_node("BossBanner"))
	await create_timer(1.2).timeout
	assert(feedback.get_child_count() == 0)

	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.combat_feedback != null)
	assert(game.combat_audio_manager != null)
	var created_before: int = int(game.combat_feedback.get("feedback_created"))
	game.apply_damage_to_enemy(game.enemy, 9)
	assert(int(game.combat_feedback.get("feedback_created")) >= created_before + 1)
	game.configure_accessibility({"reduced_motion": true, "high_contrast": true})
	assert(bool(game.combat_feedback.get("reduced_motion")))
	assert(bool(game.combat_feedback.get("high_contrast")))
	for index: int in range(70):
		game.combat_feedback.call("show_damage", Vector2(600.0, 500.0), index, true)
	assert(game.combat_feedback.get_child_count() <= 48)
	game.combat_feedback.call("show_boss_banner", "WARNING", Color.ORANGE)
	for index: int in range(70):
		game.combat_feedback.call("show_damage", Vector2.ZERO, index, true)
	assert(game.combat_feedback.has_node("BossBanner"))
	assert(game.combat_feedback.get_child_count() <= 48)
	game.free()
	feedback.free()
	print("COMBAT FEEDBACK V1 VALIDATION: PASS")
	quit()
