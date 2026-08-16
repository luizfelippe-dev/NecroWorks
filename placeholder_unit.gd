@tool
extends Node2D

@export var unit_color: Color = Color.WHITE:
	set(value):
		unit_color = value
		queue_redraw()

@export var unit_size: Vector2 = Vector2(70.0, 70.0):
	set(value):
		unit_size = value
		queue_redraw()


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(
		Vector2(
			-unit_size.x / 2.0,
			-unit_size.y / 2.0
		),
		unit_size
	)

	draw_rect(
		rect,
		unit_color,
		true
	)
