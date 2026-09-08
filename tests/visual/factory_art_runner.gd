extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var art: TextureRect = game.factory_panel.get_node_or_null("FactoryMachineryArt")
	assert(art != null)
	assert(art.texture != null)
	assert(art.texture.get_width() <= 1024)
	assert(art.texture.get_width() > art.texture.get_height())
	assert(art.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	assert(art.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	assert(art.modulate.a <= 0.35)
	print("FACTORY PHYSICAL ART LAYER: PASS")
	game.queue_free()
	await process_frame
	quit()
