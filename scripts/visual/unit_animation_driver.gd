extends Node

signal animation_started(animation_name: String)
signal animation_finished(animation_name: String)

const IDLE := "idle"
const MOVE := "move"
const ATTACK := "attack"
const HIT := "hit"
const DEATH := "death"
const SUPPORTED_ANIMATIONS: Array[String] = [IDLE, MOVE, ATTACK, HIT, DEATH]
const MOTION_SHADER: Shader = preload("res://scripts/visual/unit_motion.gdshader")
const MOVE_DURATION := 0.48
const ATTACK_DURATION := 0.32
const HIT_DURATION := 0.14
const DEATH_DURATION := 0.22

var sprite: Sprite2D
var current_animation: String = IDLE
var base_texture: Texture2D
var state_textures: Dictionary = {}
var frame_sequences: Dictionary = {}
var base_position: Vector2
var base_scale: Vector2
var base_modulate: Color
var reduced_motion := false
var action_elapsed := 0.0
var gait_phase := 0.0
var locomotion_weight := 0.0
var movement_grace := 0.0
var observed_motion_grace := 0.0
var hit_remaining := 0.0
var idle_time := 0.0
var facing := 1.0
var previous_world_position: Vector2
var motion_material: ShaderMaterial
var profile: Dictionary = {}
var death_finished := false
static var texture_bounds: Dictionary = {}


func bind(target_sprite: Sprite2D) -> void:
	sprite = target_sprite
	base_texture = sprite.texture
	base_position = sprite.position
	base_scale = sprite.scale
	base_modulate = sprite.modulate
	previous_world_position = sprite.get_parent().global_position
	motion_material = ShaderMaterial.new()
	motion_material.shader = MOTION_SHADER
	sprite.material = motion_material
	set_process(true)


func configure_motion(motion_profile: Dictionary) -> void:
	profile = motion_profile.duplicate()
	facing = float(profile.get("facing", 1.0))
	motion_material.set_shader_parameter("facing", facing)
	motion_material.set_shader_parameter("spectral", float(profile.get("spectral", 0.0)))
	motion_material.set_shader_parameter("stride", float(profile.get("stride", 0.045)))
	motion_material.set_shader_parameter("leg_split", float(profile.get("leg_split", 0.5)))
	motion_material.set_shader_parameter("leg_root", float(profile.get("leg_root", 0.6)))


func configure_state_textures(textures: Dictionary) -> bool:
	var validated: Dictionary = {}
	for animation_name: Variant in textures:
		var state := str(animation_name)
		if state not in SUPPORTED_ANIMATIONS or not textures[animation_name] is Texture2D:
			return false
		validated[state] = textures[animation_name]
	state_textures = validated
	_apply_state_texture(current_animation)
	return true


func configure_frame_sequences(sequences: Dictionary) -> bool:
	var validated: Dictionary = {}
	for animation_name: Variant in sequences:
		var state := str(animation_name)
		var frames: Variant = sequences[animation_name]
		if state not in [MOVE, ATTACK] or not frames is Array or frames.size() < 2:
			return false
		for frame: Variant in frames:
			if not frame is Texture2D:
				return false
		validated[state] = frames.duplicate()
	frame_sequences = validated
	return true


func play(animation_name: String, _direction: float = 1.0) -> bool:
	if sprite == null or animation_name not in SUPPORTED_ANIMATIONS:
		return false
	if current_animation == DEATH:
		return animation_name == DEATH
	# Damage feedback is an independent layer, never a cancellation of locomotion/attack.
	if animation_name == HIT:
		hit_remaining = HIT_DURATION
		if current_animation in [ATTACK, MOVE]:
			return true
	if animation_name == MOVE:
		movement_grace = MOVE_DURATION
		if current_animation in [ATTACK, MOVE]:
			return true
	if animation_name == current_animation:
		return true
	current_animation = animation_name
	action_elapsed = 0.0
	_apply_state_texture(animation_name)
	animation_started.emit(animation_name)
	if animation_name == DEATH:
		movement_grace = 0.0
		locomotion_weight = 0.0
		hit_remaining = 0.0
	_render_pose()
	return true


func _process(delta: float) -> void:
	if sprite != null:
		advance(delta, sprite.get_parent().global_position)


func advance(delta: float, world_position: Vector2) -> void:
	if sprite == null or delta <= 0.0:
		return
	var distance := world_position.distance_to(previous_world_position)
	previous_world_position = world_position
	var moving := distance > 0.015 and distance < 100.0
	if moving:
		observed_motion_grace = 0.08
		if current_animation == IDLE:
			play(MOVE)
		movement_grace = 0.08
	else:
		observed_motion_grace = maxf(0.0, observed_motion_grace - delta)
		movement_grace = maxf(0.0, movement_grace - delta)
	if current_animation == MOVE and movement_grace <= 0.0:
		_finish_action(MOVE)
	var target_weight := 1.0 if current_animation == MOVE and observed_motion_grace > 0.0 else 0.0
	locomotion_weight = lerpf(locomotion_weight, target_weight, 1.0 - exp(-18.0 * delta))
	var pace := clampf(distance / delta / 90.0, 0.65, 1.55) if moving else 1.0
	gait_phase += delta * TAU / float(profile.get("walk_period", 0.56)) * pace
	idle_time += delta
	action_elapsed += delta
	hit_remaining = maxf(0.0, hit_remaining - delta)
	if current_animation == ATTACK and action_elapsed >= float(profile.get("attack_duration", ATTACK_DURATION)):
		_finish_action(ATTACK)
	elif current_animation == HIT and action_elapsed >= HIT_DURATION:
		_finish_action(HIT)
	_render_pose()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if sprite != null:
		_render_pose()


func _render_pose() -> void:
	sprite.position = base_position
	sprite.scale = base_scale
	sprite.modulate = base_modulate
	sprite.rotation = 0.0
	var strike := 0.0
	if current_animation == DEATH:
		var death_progress := 1.0 if reduced_motion or death_finished else clampf(action_elapsed / DEATH_DURATION, 0.0, 1.0)
		sprite.modulate.a = base_modulate.a * (1.0 - death_progress)
		if not reduced_motion:
			sprite.position.y += 3.0 * death_progress
		if death_progress >= 1.0 and not death_finished:
			death_finished = true
			animation_finished.emit(DEATH)
	elif not reduced_motion:
		sprite.position.y -= absf(sin(gait_phase)) * float(profile.get("bob", 1.15)) * locomotion_weight
		sprite.position.y += sin(idle_time * 2.4) * 0.45 * (1.0 - locomotion_weight)
		sprite.rotation = sin(gait_phase) * 0.009 * locomotion_weight
		if current_animation == ATTACK:
			var phase := clampf(action_elapsed / float(profile.get("attack_duration", ATTACK_DURATION)), 0.0, 1.0)
			# Combat has already emitted the impact. Recover smoothly from that pose.
			var recovery := smoothstep(0.0, 0.08, phase) * (1.0 - smoothstep(0.08, 1.0, phase))
			strike = recovery
			sprite.position.x += facing * float(profile.get("attack_travel", 6.0)) * recovery
			sprite.rotation += facing * 0.025 * recovery
		if hit_remaining > 0.0:
			sprite.position.x -= facing * sin(hit_remaining / HIT_DURATION * PI) * 1.8
	if hit_remaining > 0.0 and current_animation != DEATH:
		sprite.modulate = base_modulate.lerp(Color(1.0, 0.48, 0.38, base_modulate.a), hit_remaining / HIT_DURATION * 0.65)
	motion_material.set_shader_parameter("phase", gait_phase)
	motion_material.set_shader_parameter("movement", 0.0 if reduced_motion or current_animation == DEATH else locomotion_weight)
	motion_material.set_shader_parameter("strike", strike)
	var frames: Array = frame_sequences.get(current_animation, [])
	sprite.material = null if not frames.is_empty() else motion_material
	if not frames.is_empty() and not reduced_motion:
		var progress := fmod(gait_phase / TAU, 1.0) if current_animation == MOVE else action_elapsed / float(profile.get("attack_duration", ATTACK_DURATION))
		_set_texture(frames[mini(int(progress * frames.size()), frames.size() - 1)])
		if sprite.texture is AtlasTexture:
			# Sheet cells have a shared ground line. Never stretch each pose separately.
			var ratio: float = base_texture.get_height() / float(sprite.texture.get_height()) * 0.85
			sprite.scale = base_scale * ratio
			sprite.rotation = 0.0
		var rest_bounds: Vector4 = texture_bounds[base_texture]
		var frame_bounds: Vector4 = texture_bounds[sprite.texture]
		var rest_floor: float = (rest_bounds.y + rest_bounds.w - 0.5) * base_texture.get_height() * base_scale.y
		var frame_floor: float = (frame_bounds.y + frame_bounds.w - 0.5) * sprite.texture.get_height() * sprite.scale.y
		sprite.position.y = base_position.y + rest_floor - frame_floor
	elif not frames.is_empty():
		_apply_state_texture(current_animation)


func _finish_action(completed_animation: String) -> void:
	current_animation = MOVE if observed_motion_grace > 0.0 else IDLE
	action_elapsed = 0.0
	_apply_state_texture(current_animation)
	animation_finished.emit(completed_animation)


func _apply_state_texture(animation_name: String) -> void:
	if sprite != null:
		_set_texture(state_textures.get(animation_name, base_texture))


func _set_texture(texture: Texture2D) -> void:
	if texture == null:
		return
	sprite.texture = texture
	if not texture_bounds.has(texture):
		var source := texture.get_image()
		var bounds := Vector4(0.0, 0.0, 1.0, 1.0)
		if source != null:
			if source.is_compressed():
				source.decompress()
			var used := source.get_used_rect()
			var dimensions := Vector2(source.get_size())
			bounds = Vector4(used.position.x / dimensions.x, used.position.y / dimensions.y, used.size.x / dimensions.x, used.size.y / dimensions.y)
		texture_bounds[texture] = bounds
	motion_material.set_shader_parameter("body_bounds", texture_bounds[texture])
