extends Node2D


const VIEWPORT_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const BACKGROUND_TEXTURE: Texture2D = preload(
	"res://assets/backgrounds/necroworks_factory_battlefield_v1.png"
)
const GREEN: Color = Color(0.31, 0.78, 0.22, 1.0)
const GREEN_DIM: Color = Color(0.12, 0.31, 0.10, 1.0)
const METAL_LIGHT: Color = Color(0.16, 0.17, 0.15, 1.0)

var background_sprite: Sprite2D
var atmosphere_time: float = 0.0
var redraw_timer: float = 0.0


func _ready() -> void:
	background_sprite = Sprite2D.new()
	background_sprite.name = "FactoryArtwork"
	background_sprite.texture = BACKGROUND_TEXTURE
	background_sprite.centered = false
	background_sprite.z_index = -10
	var texture_size: Vector2 = BACKGROUND_TEXTURE.get_size()
	background_sprite.scale = Vector2(
		VIEWPORT_SIZE.x / maxf(texture_size.x, 1.0),
		VIEWPORT_SIZE.y / maxf(texture_size.y, 1.0)
	) * 1.015
	background_sprite.position = Vector2(-14.0, -8.0)
	add_child(background_sprite)
	queue_redraw()


func _process(delta: float) -> void:
	atmosphere_time += delta
	redraw_timer += delta
	if background_sprite != null:
		background_sprite.position.x = -14.0 + sin(atmosphere_time * 0.08) * 4.0
		background_sprite.position.y = -8.0 + cos(atmosphere_time * 0.06) * 2.0
	if redraw_timer >= 0.08:
		redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	# Leitura do combate: a arte permanece presente sem competir com HP e nomes.
	draw_rect(
		Rect2(Vector2.ZERO, VIEWPORT_SIZE),
		Color(0.005, 0.008, 0.008, 0.24)
	)
	draw_rect(
		Rect2(0.0, 292.0, 1920.0, 520.0),
		Color(0.01, 0.016, 0.012, 0.20)
	)

	# Névoa em planos lentos cria profundidade sem uma segunda textura pesada.
	for layer: int in range(4):
		var phase: float = atmosphere_time * (0.14 + float(layer) * 0.025)
		var fog_y: float = 350.0 + float(layer) * 112.0 + sin(phase) * 12.0
		var fog_alpha: float = 0.026 + float(layer) * 0.008
		draw_rect(
			Rect2(-40.0, fog_y, 2000.0, 64.0),
			Color(0.18, 0.28, 0.16, fog_alpha)
		)

	# Linhas do piso reforçam a direção horizontal das duas formações.
	for stripe: int in range(9):
		var stripe_y: float = 372.0 + float(stripe) * 51.0
		draw_line(
			Vector2(0.0, stripe_y),
			Vector2(1920.0, stripe_y + 11.0),
			Color(0.16, 0.20, 0.13, 0.16),
			1.5
		)

	# Pulsos discretos preservam a linguagem necromântica do layout alvo.
	for lamp: int in range(7):
		var lamp_x: float = 210.0 + float(lamp) * 250.0
		var pulse: float = 0.72 + sin(atmosphere_time * 1.4 + float(lamp)) * 0.18
		draw_circle(
			Vector2(lamp_x, 286.0),
			10.0,
			Color(GREEN.r, GREEN.g, GREEN.b, 0.055 * pulse)
		)
		draw_circle(
			Vector2(lamp_x, 286.0),
			3.0,
			Color(GREEN.r, GREEN.g, GREEN.b, 0.35 * pulse)
		)

	# Divisor da área de produção continua procedural para alinhar com o HUD.
	draw_rect(Rect2(0.0, 805.0, 1920.0, 18.0), Color(0.03, 0.035, 0.031, 0.82))
	draw_line(Vector2(0.0, 806.0), Vector2(1920.0, 806.0), METAL_LIGHT, 4.0)
	draw_line(Vector2(0.0, 819.0), Vector2(1920.0, 819.0), GREEN_DIM, 2.0)
