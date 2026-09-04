extends SceneTree


const CATALOG: Script = preload("res://scripts/visual/unit_sprite_catalog.gd")
const STATES: Array[String] = ["idle", "move", "attack", "hit", "death"]


func _initialize() -> void:
	var textures: Dictionary = CATALOG.get_animation_textures("elf")
	assert(textures.size() == STATES.size())
	for state: String in STATES:
		assert(state in textures)
		var texture: Texture2D = textures[state] as Texture2D
		assert(texture != null)
		assert(texture.get_width() == 512)
		assert(texture.get_height() == 512)
		var image: Image = texture.get_image()
		assert(not image.is_empty())
		assert(image.get_pixel(0, 0).a < 0.01)
	assert(CATALOG.get_canvas_scale_multiplier("elf") > 0.0)
	print("ELF ANIMATION ASSETS VALIDATION: PASS")
	quit()
