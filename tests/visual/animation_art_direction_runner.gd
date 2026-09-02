extends SceneTree


const CONCEPT_SHEETS: Array[String] = [
	"res://assets/sprites/animation_concepts/skeleton_warrior_five_state_v1.png",
	"res://assets/sprites/animation_concepts/zombie_tank_five_state_v1.png",
]


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	for asset_path: String in CONCEPT_SHEETS:
		assert(ResourceLoader.exists(asset_path))
		var texture: Texture2D = load(asset_path) as Texture2D
		assert(texture != null)
		assert(texture.get_width() == 2172)
		assert(texture.get_height() == 724)
		var image: Image = texture.get_image()
		assert(not image.is_empty())
		assert(image.get_pixel(0, 0).a < 0.01)
		assert(image.get_pixel(image.get_width() - 1, 0).a < 0.01)
	print("ANIMATION ART DIRECTION VALIDATION: PASS")
	quit()
