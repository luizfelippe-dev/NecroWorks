extends Node


const SAMPLE_RATE: int = 22050
const LOOP_SECONDS: float = 8.0

var player: AudioStreamPlayer = null


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "IndustrialAmbience"
	player.bus = &"Music"
	player.volume_db = -13.0
	player.stream = create_ambient_loop()
	add_child(player)
	if not DisplayServer.get_name().to_lower().contains("headless"):
		player.play()


func create_ambient_loop() -> AudioStreamWAV:
	var sample_count: int = int(float(SAMPLE_RATE) * LOOP_SECONDS)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for index: int in range(sample_count):
		var t: float = float(index) / float(SAMPLE_RATE)
		var seam_envelope: float = 0.82 + 0.18 * sin(TAU * t / LOOP_SECONDS)
		var drone: float = sin(TAU * 46.0 * t) * 0.42
		drone += sin(TAU * 69.0 * t + 0.7) * 0.20
		var machine_pulse: float = pow(maxf(sin(TAU * 0.5 * t), 0.0), 9.0) * 0.25
		var sample: int = clampi(
			int((drone + machine_pulse) * seam_envelope * 0.16 * 32767.0),
			-32768,
			32767
		)
		bytes.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = bytes
	return stream
