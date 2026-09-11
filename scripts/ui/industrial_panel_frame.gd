extends Control

var accent := Color("796c4d")


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if size.x < 24.0 or size.y < 24.0:
		return
	draw_rect(Rect2(Vector2(5, 5), size - Vector2(10, 10)), accent.darkened(0.55), false)
	draw_line(Vector2(20, 2), Vector2(size.x - 20, 2), accent.lightened(0.24), 1.0)
	draw_line(Vector2(20, size.y - 3), Vector2(size.x - 20, size.y - 3), Color(0, 0, 0, 0.7), 2.0)
	for corner: Vector2 in [Vector2(8, 8), Vector2(size.x - 8, 8), Vector2(8, size.y - 8), size - Vector2(8, 8)]:
		draw_circle(corner, 3.0, accent.darkened(0.45))
		draw_arc(corner, 2.0, PI, TAU, 8, accent.lightened(0.3), 1.0, true)
	for x: float in [18.0, size.x - 18.0]:
		draw_line(Vector2(x, 1), Vector2(x, 8), accent, 2.0)
		draw_line(Vector2(x, size.y - 8), Vector2(x, size.y - 1), accent, 2.0)
