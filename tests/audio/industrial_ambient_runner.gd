extends SceneTree


const AMBIENT_SCRIPT: Script = preload("res://scripts/audio/industrial_ambient_manager.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var ambient: Node = AMBIENT_SCRIPT.new()
	root.add_child(ambient)
	await process_frame
	var player: AudioStreamPlayer = ambient.get("player") as AudioStreamPlayer
	assert(player != null)
	assert(player.bus == &"Music")
	var stream: AudioStreamWAV = player.stream as AudioStreamWAV
	assert(stream != null)
	assert(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	assert(stream.loop_begin == 0)
	assert(stream.loop_end == int(AMBIENT_SCRIPT.SAMPLE_RATE * AMBIENT_SCRIPT.LOOP_SECONDS))
	assert(stream.data.size() == stream.loop_end * 2)
	assert(AudioServer.get_bus_index("Music") >= 0)
	assert(AudioServer.get_bus_index("SFX") >= 0)
	assert(AudioServer.get_bus_index("UI") >= 0)
	ambient.queue_free()
	await process_frame
	print("INDUSTRIAL AMBIENT AND AUDIO BUSES: PASS")
	quit()
