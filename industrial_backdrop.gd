extends Node2D


const VIEWPORT_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const GREEN: Color = Color(0.31, 0.78, 0.22, 1.0)
const GREEN_DIM: Color = Color(0.12, 0.31, 0.10, 1.0)
const METAL: Color = Color(0.08, 0.09, 0.085, 1.0)
const METAL_LIGHT: Color = Color(0.16, 0.17, 0.15, 1.0)
const FLOOR: Color = Color(0.075, 0.085, 0.07, 1.0)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, VIEWPORT_SIZE),
		Color(0.012, 0.016, 0.017, 1.0)
	)

	# Silhueta da fábrica: chaminés, tanques e tubulações.
	for index: int in range(13):
		var x_position: float = 35.0 + float(index) * 151.0
		var tower_height: float = 115.0 + float((index * 47) % 155)
		var tower_width: float = 42.0 + float((index * 13) % 48)
		var tower_rect: Rect2 = Rect2(
			Vector2(x_position, 290.0 - tower_height),
			Vector2(tower_width, tower_height)
		)
		draw_rect(tower_rect, METAL)
		draw_rect(tower_rect, METAL_LIGHT, false, 3.0)
		draw_rect(
			Rect2(
				Vector2(x_position + tower_width * 0.42, 305.0 - tower_height),
				Vector2(10.0, tower_height + 15.0)
			),
			Color(0.045, 0.05, 0.047, 1.0)
		)
		if index % 2 == 0:
			draw_circle(
				Vector2(x_position + tower_width * 0.5, 260.0),
				6.0,
				GREEN_DIM
			)

	# Linha de batalha com faixas industriais e névoa necromântica.
	draw_rect(Rect2(0.0, 285.0, 1920.0, 535.0), FLOOR)
	for stripe: int in range(11):
		var stripe_y: float = 315.0 + float(stripe) * 47.0
		draw_line(
			Vector2(0.0, stripe_y),
			Vector2(1920.0, stripe_y + 18.0),
			Color(0.11, 0.125, 0.095, 0.45),
			2.0
		)

	draw_rect(
		Rect2(0.0, 805.0, 1920.0, 18.0),
		Color(0.03, 0.035, 0.031, 1.0)
	)
	draw_line(
		Vector2(0.0, 806.0),
		Vector2(1920.0, 806.0),
		METAL_LIGHT,
		4.0
	)
	draw_line(
		Vector2(0.0, 819.0),
		Vector2(1920.0, 819.0),
		GREEN_DIM,
		2.0
	)

	# Trilhos/esteira da faixa de produção.
	draw_rect(Rect2(0.0, 823.0, 1920.0, 257.0), Color(0.018, 0.022, 0.021, 1.0))
	for roller: int in range(40):
		var roller_x: float = 18.0 + float(roller) * 49.0
		draw_circle(Vector2(roller_x, 1052.0), 8.0, METAL_LIGHT)
		draw_circle(Vector2(roller_x, 1052.0), 3.0, Color(0.025, 0.03, 0.027, 1.0))

	# Luminárias verdes discretas que repetem a linguagem do concept.
	for lamp: int in range(7):
		var lamp_x: float = 210.0 + float(lamp) * 250.0
		draw_line(
			Vector2(lamp_x, 255.0),
			Vector2(lamp_x, 282.0),
			METAL_LIGHT,
			5.0
		)
		draw_circle(Vector2(lamp_x, 286.0), 7.0, GREEN)
