extends SceneTree


const AUDIO_SCRIPT: Script = preload("res://scripts/audio/combat_audio_manager.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var audio: Node = AUDIO_SCRIPT.new()
	root.add_child(audio)
	await process_frame
	var sounds: Dictionary = audio.get("sounds") as Dictionary
	var players: Array = audio.get("players") as Array
	assert(sounds.size() == 9)
	assert(players.size() == 10)
	for event_id: String in [
		"attack", "hit", "death", "ability", "boss", "wave",
		"processing", "production", "machine_blocked"
	]:
		var stream: AudioStreamWAV = sounds[event_id] as AudioStreamWAV
		assert(stream != null)
		assert(stream.data.size() > 100)
	for player_value: Variant in players:
		assert((player_value as AudioStreamPlayer).bus == &"SFX")
	assert(audio.call("play_event", "attack"))
	assert(not audio.call("play_event", "attack"))
	assert(audio.call("play_event", "ability"))
	assert(not audio.call("play_event", "missing"))
	assert(audio.call("play_event", "boss"))
	var boss_stream: AudioStream = audio.boss_voice.stream
	for _index: int in range(30):
		assert(audio.call("play_event", "production"))
	assert(audio.boss_voice.stream == boss_stream)
	assert(audio.boss_voice not in players, "Regular effects must never steal the boss voice")
	assert(int((audio.get("played_events") as Dictionary).get("attack", 0)) == 1)
	await create_timer(0.7).timeout
	for player_value: Variant in players:
		var player: AudioStreamPlayer = player_value as AudioStreamPlayer
		player.stop()
		player.stream = null
	sounds.clear()
	audio.queue_free()
	await process_frame
	await process_frame
	print("PROCEDURAL COMBAT AUDIO VALIDATION: PASS")
	quit()
