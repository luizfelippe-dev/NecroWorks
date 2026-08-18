extends Node2D


const BAR_HEIGHT: float = 9.0
const BORDER_WIDTH: float = 2.0
const BACKGROUND_COLOR: Color = Color(0.015, 0.018, 0.016, 0.96)
const BORDER_COLOR: Color = Color(0.68, 0.66, 0.54, 0.95)
const LOW_HEALTH_COLOR: Color = Color(0.90, 0.12, 0.08, 1.0)

var current_health: int = 1
var maximum_health: int = 1
var bar_width: float = 76.0
var base_color: Color = Color(0.35, 0.82, 0.22, 1.0)


func configure(
	maximum: int,
	current: int,
	width: float,
	vertical_offset: float,
	fill_color: Color
) -> void:

	maximum_health = maxi(maximum, 1)
	current_health = clampi(current, 0, maximum_health)
	bar_width = maxf(width, 24.0)
	position = Vector2(0.0, vertical_offset)
	base_color = fill_color
	queue_redraw()


func set_health(
	current: int,
	maximum: int
) -> void:

	maximum_health = maxi(maximum, 1)
	current_health = clampi(current, 0, maximum_health)
	queue_redraw()


func _draw() -> void:

	var outer_rect: Rect2 = Rect2(
		Vector2(-bar_width * 0.5, -BAR_HEIGHT * 0.5),
		Vector2(bar_width, BAR_HEIGHT)
	)
	draw_rect(outer_rect, BACKGROUND_COLOR, true)

	var ratio: float = clampf(
		float(current_health) / float(maximum_health),
		0.0,
		1.0
	)
	var inner_width: float = maxf(
		(bar_width - BORDER_WIDTH * 2.0) * ratio,
		0.0
	)
	var danger_weight: float = clampf(
		(0.40 - ratio) / 0.40,
		0.0,
		1.0
	)
	var health_color: Color = base_color.lerp(
		LOW_HEALTH_COLOR,
		danger_weight
	)

	if inner_width > 0.0:
		draw_rect(
			Rect2(
				Vector2(
					-bar_width * 0.5 + BORDER_WIDTH,
					-BAR_HEIGHT * 0.5 + BORDER_WIDTH
				),
				Vector2(
					inner_width,
					BAR_HEIGHT - BORDER_WIDTH * 2.0
				)
			),
			health_color,
			true
		)

	draw_rect(outer_rect, BORDER_COLOR, false, BORDER_WIDTH)
