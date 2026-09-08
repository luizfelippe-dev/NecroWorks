extends Node


const SAMPLE_RATE: int = 22050
const PLAYER_POOL_SIZE: int = 10

var sounds: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var next_player: int = 0
var hit_cooldown: float = 0.0
var attack_cooldown: float = 0.0
var played_events: Dictionary = {}


func _ready() -> void:
	sounds = {
		"attack": create_tone(320.0, 180.0, 0.08, 0.18, 0.34),
		"hit": create_tone(150.0, 92.0, 0.07, 0.56, 0.42),
		"death": create_tone(118.0, 48.0, 0.22, 0.22, 0.42),
		"ability": create_tone(270.0, 620.0, 0.30, 0.10, 0.30),
		"boss": create_tone(82.0, 42.0, 0.52, 0.12, 0.50),
		"wave": create_tone(210.0, 340.0, 0.24, 0.04, 0.26),
		"processing": create_tone(92.0, 210.0, 0.24, 0.32, 0.34),
		"production": create_tone(180.0, 430.0, 0.20, 0.08, 0.30),
		"machine_blocked": create_tone(105.0, 72.0, 0.14, 0.18, 0.28),
	}
	for index: int in range(PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "CombatVoice%d" % index
		player.volume_db = -8.0
		player.bus = &"SFX"
		add_child(player)
		players.append(player)


func _process(delta: float) -> void:
	hit_cooldown = maxf(hit_cooldown - delta, 0.0)
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)


func play_event(event_id: String) -> bool:
	if event_id not in sounds or players.is_empty():
		return false
	if event_id == "hit" and hit_cooldown > 0.0:
		return false
	if event_id == "attack" and attack_cooldown > 0.0:
		return false
	if event_id == "hit":
		hit_cooldown = 0.045
	if event_id == "attack":
		attack_cooldown = 0.035
	var player: AudioStreamPlayer = players[next_player]
	next_player = (next_player + 1) % players.size()
	player.stream = sounds[event_id] as AudioStream
	player.pitch_scale = 0.96 + float(int(played_events.get(event_id, 0)) % 5) * 0.02
	if not DisplayServer.get_name().to_lower().contains("headless"):
		player.play()
	played_events[event_id] = int(played_events.get(event_id, 0)) + 1
	return true


func create_tone(
	start_frequency: float,
	end_frequency: float,
	duration: float,
	noise_amount: float,
	volume: float
) -> AudioStreamWAV:
	var sample_count: int = maxi(int(float(SAMPLE_RATE) * duration), 1)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var phase: float = 0.0
	for index: int in range(sample_count):
		var progress: float = float(index) / float(sample_count)
		var frequency: float = lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / float(SAMPLE_RATE)
		var envelope: float = pow(1.0 - progress, 2.2) * minf(progress * 18.0, 1.0)
		var pseudo_noise: float = sin(float(index * 73 + 19)) * noise_amount
		var wave: float = (sin(phase) * (1.0 - noise_amount) + pseudo_noise)
		var sample: int = clampi(int(wave * envelope * volume * 32767.0), -32768, 32767)
		bytes.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
