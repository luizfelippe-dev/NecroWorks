extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	var backdrop: Node2D = game.get_node("IndustrialBackdrop") as Node2D
	var artwork: Sprite2D = backdrop.get_node_or_null("FactoryArtwork") as Sprite2D
	assert(artwork != null)
	assert(artwork.texture != null)
	assert(artwork.texture.get_width() >= 1280)
	assert(artwork.texture.get_height() >= 720)
	assert(artwork.z_index < 0)
	assert(artwork.scale.x > 1.0 and artwork.scale.y > 1.0)
	var initial_position: Vector2 = artwork.position
	backdrop.call("_process", 2.0)
	assert(artwork.position != initial_position)
	game.free()
	print("HYBRID BACKDROP VALIDATION: PASS")
	quit()
