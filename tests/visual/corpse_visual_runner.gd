extends SceneTree


const CORPSE_SCENE: PackedScene = preload("res://scenes/world/corpse.tscn")
const CATALOG: Script = preload("res://scripts/visual/corpse_visual_catalog.gd")


func _initialize() -> void:
	assert(CATALOG.get_family("human_warrior") == "armored")
	assert(CATALOG.get_family("mage") == "arcane")
	assert(CATALOG.get_family("elf") == "agile")
	assert(
		CATALOG.get_family("grave_marshal", true)
		== "grave_marshal_remains"
	)
	assert(
		CATALOG.get_family("arcane_auditor", true)
		== "arcane_auditor_remains"
	)
	assert(CATALOG.get_family("foreman", true) == "foreman_remains")

	var corpse: Button = CORPSE_SCENE.instantiate() as Button
	root.add_child(corpse)
	corpse.call("configure_visual", "arcane_auditor", false, true)
	corpse.call("set_display_text", "ARCANE REMAINS")
	var sprite: Sprite2D = corpse.get_node_or_null("CorpseSprite") as Sprite2D
	var label: Label = corpse.get_node_or_null("IdentityLabel") as Label
	assert(sprite != null and sprite.texture != null)
	assert(label != null and label.text == "ARCANE REMAINS")
	assert(str(corpse.get_meta("visual_family")) == "arcane_auditor_remains")
	corpse.free()
	print("CORPSE VISUAL FAMILIES VALIDATION: PASS")
	quit()
