extends Control

var kind: String = "bones"
var tint := Color("e8dec0")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.36
	draw_circle(center, radius + 4.0, Color(tint, 0.06))
	match kind:
		"bones":
			var start := center + Vector2(-radius * 0.6, radius * 0.6)
			var end := center + Vector2(radius * 0.6, -radius * 0.6)
			draw_line(start, end, tint, radius * 0.34, true)
			for endpoint: Vector2 in [start, end]:
				draw_circle(endpoint + Vector2(-2, -2), radius * 0.25, tint)
				draw_circle(endpoint + Vector2(2, 2), radius * 0.25, tint)
		"flesh":
			var points := PackedVector2Array([
				center + Vector2(-radius, radius * 0.4), center + Vector2(-radius * 0.7, -radius * 0.6),
				center + Vector2(radius * 0.2, -radius), center + Vector2(radius, -radius * 0.1),
				center + Vector2(radius * 0.5, radius * 0.8), center + Vector2(-radius * 0.4, radius),
			])
			draw_colored_polygon(points, tint.darkened(0.3))
			points.append(points[0])
			draw_polyline(points, tint, 1.5, true)
			draw_arc(center, radius * 0.4, -PI * 0.6, PI * 0.5, 12, tint.lightened(0.3), 2.0, true)
		"blood":
			var points := PackedVector2Array([center + Vector2(0, -radius)])
			for index: int in range(17):
				var angle := float(index) / 16.0 * PI
				points.append(center + Vector2(cos(angle) * radius * 0.7, sin(angle) * radius * 0.8))
			draw_colored_polygon(points, tint)
			draw_line(center + Vector2(-3, 0), center + Vector2(-3, 4), tint.lightened(0.5), 2, true)
		"souls":
			var points := PackedVector2Array()
			for index: int in range(40):
				var progress := float(index) / 39.0
				var angle := progress * TAU * 1.6
				points.append(center + Vector2(cos(angle), sin(angle)) * radius * progress)
			draw_polyline(points, tint, 2.0, true)
			draw_circle(center, 2.0, tint.lightened(0.4))
