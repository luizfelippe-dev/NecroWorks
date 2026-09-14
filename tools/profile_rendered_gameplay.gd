extends SceneTree

# Rendered frame intervals, not GPU timings or a minimum-spec certification.
const GAME := preload("res://scenes/world/gameplay.tscn")
const WARMUP := 120
const SAMPLES := 360

func _initialize() -> void:
	call_deferred("profile_run")

func profile_run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Run this profiler with a rendering window, not --headless.")
		quit(1)
		return
	seed(6014)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var game: Node = GAME.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	for enemy: Node in game.enemies:
		enemy.queue_free()
	await process_frame
	for index: int in range(19):
		assert(game.create_free_skeleton("RENDER PROFILE"))
	for index: int in range(10):
		assert(game.create_free_zombie("RENDER PROFILE"))
	for index: int in range(6):
		assert(game.create_free_ghost())
	game.start_wave(18)
	game.set_process(true)
	for frame: int in range(WARMUP):
		await RenderingServer.frame_post_draw
	var army_start: int = game.get_total_undead_count()
	var intervals: Array[float] = []
	var peak_memory: float = 0
	var last_us: int = Time.get_ticks_usec()
	for frame: int in range(SAMPLES):
		await RenderingServer.frame_post_draw
		var now: int = Time.get_ticks_usec()
		intervals.append(float(now - last_us) / 1000.0)
		last_us = now
		peak_memory = maxf(peak_memory, Performance.get_monitor(Performance.MEMORY_STATIC))
	var total: float = 0
	for interval: float in intervals:
		total += interval
	intervals.sort()
	var report: Dictionary = {
		"engine": Engine.get_version_info().string,
		"adapter": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"viewport": str(root.get_visible_rect().size),
		"window": str(DisplayServer.window_get_size()),
		"warmup_frames": WARMUP, "samples": SAMPLES, "seed": 6014,
		"mean_interval_ms": total / SAMPLES,
		"p50_ms": intervals[int(SAMPLES * 0.50)],
		"p95_ms": intervals[int(SAMPLES * 0.95)],
		"p99_ms": intervals[int(SAMPLES * 0.99)],
		"peak_engine_static_bytes": peak_memory,
		"army_start": army_start, "army_end": game.get_total_undead_count(),
		"wave_end": game.current_wave, "enemies_end": game.enemies.size(),
		"kills": game.total_enemies_killed,
		"note": "Fixed simulation step recommended; uncapped rendered intervals include CPU/render scheduling, not GPU latency. Debug executable; no player saves.",
	}
	var label := "sample"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--label="):
			label = argument.trim_prefix("--label=").validate_filename()
	DirAccess.make_dir_recursive_absolute("res://artifacts/performance")
	var file := FileAccess.open("res://artifacts/performance/" + label + ".json", FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("RENDERED PROFILE: ", JSON.stringify(report))
	game.queue_free()
	await process_frame
	quit()
