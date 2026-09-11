extends Node


signal animation_started(animation_name: String)
signal animation_finished(animation_name: String)

const IDLE: String = "idle"
const MOVE: String = "move"
const ATTACK: String = "attack"
const HIT: String = "hit"
const DEATH: String = "death"
const SUPPORTED_ANIMATIONS: Array[String] = [IDLE, MOVE, ATTACK, HIT, DEATH]
const MOVE_DURATION: float = 0.32
const ATTACK_DURATION: float = 0.28

var sprite: Sprite2D
var blend_sprite: Sprite2D
var current_animation: String = IDLE
var base_texture: Texture2D
var state_textures: Dictionary = {}
var frame_sequences: Dictionary = {}
var base_position: Vector2
var base_scale: Vector2
var base_modulate: Color
var idle_time: float = 0.0
var action_tween: Tween
var blend_tween: Tween
var reduced_motion: bool = false
var playback_generation: int = 0


func bind(target_sprite: Sprite2D) -> void:
	sprite = target_sprite
	if blend_sprite == null:
		blend_sprite = Sprite2D.new()
		blend_sprite.name = "FrameBlend"
		blend_sprite.z_index = sprite.z_index + 1
		blend_sprite.visible = false
		sprite.get_parent().add_child(blend_sprite)
	base_texture = sprite.texture
	base_position = sprite.position
	base_scale = sprite.scale
	base_modulate = sprite.modulate
	set_process(true)


func configure_state_textures(textures: Dictionary) -> bool:
	var validated: Dictionary = {}
	for animation_name: Variant in textures:
		var state: String = str(animation_name)
		var texture: Variant = textures[animation_name]
		if state not in SUPPORTED_ANIMATIONS or not texture is Texture2D:
			return false
		validated[state] = texture
	state_textures = validated
	_apply_state_texture(current_animation)
	return true


func configure_frame_sequences(sequences: Dictionary) -> bool:
	var validated: Dictionary = {}
	for animation_name: Variant in sequences:
		var state: String = str(animation_name)
		var frames: Variant = sequences[animation_name]
		if state not in [MOVE, ATTACK] or not frames is Array or frames.size() < 2:
			return false
		var typed_frames: Array[Texture2D] = []
		for frame: Variant in frames:
			if not frame is Texture2D:
				return false
			typed_frames.append(frame as Texture2D)
		validated[state] = typed_frames
	frame_sequences = validated
	return true


func _process(delta: float) -> void:
	_sync_blend_sprite_transform()
	if reduced_motion or sprite == null or current_animation != IDLE:
		return
	idle_time += delta
	sprite.position.y = base_position.y + sin(idle_time * 3.2) * 1.4


func play(animation_name: String, direction: float = 1.0) -> bool:
	if sprite == null or animation_name not in SUPPORTED_ANIMATIONS:
		return false
	if animation_name == MOVE and current_animation == MOVE:
		return true
	playback_generation += 1
	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual()
	current_animation = animation_name
	_apply_state_texture(animation_name)
	animation_started.emit(animation_name)
	if reduced_motion:
		_play_reduced_animation(animation_name)
		return true
	match animation_name:
		IDLE:
			_finish_action(IDLE)
		MOVE:
			_play_move(direction)
			play_frame_sequence(MOVE, MOVE_DURATION, playback_generation)
		ATTACK:
			_play_attack(direction)
			play_frame_sequence(ATTACK, ATTACK_DURATION, playback_generation)
		HIT:
			_play_hit()
		DEATH:
			_play_death()
	return true


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	playback_generation += 1
	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual()
	current_animation = IDLE
	_apply_state_texture(IDLE)
	set_process(not enabled)


func _play_reduced_animation(animation_name: String) -> void:
	if animation_name == HIT:
		sprite.modulate = Color(1.0, 0.48, 0.40, 1.0)
		await get_tree().create_timer(0.06, false).timeout
		if is_instance_valid(sprite):
			sprite.modulate = base_modulate
	elif animation_name == DEATH:
		sprite.modulate.a = 0.0
	_finish_action(animation_name)


func _play_move(direction: float) -> void:
	action_tween = create_tween()
	action_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	action_tween.set_parallel(true)
	action_tween.tween_property(
		sprite, "position:y", base_position.y - 2.2, MOVE_DURATION * 0.25
	)
	action_tween.tween_property(
		sprite, "rotation", 0.028 * signf(direction), MOVE_DURATION * 0.25
	)
	action_tween.chain().set_parallel(true)
	action_tween.tween_property(
		sprite, "position:y", base_position.y + 0.8, MOVE_DURATION * 0.25
	)
	action_tween.tween_property(
		sprite, "rotation", -0.022 * signf(direction), MOVE_DURATION * 0.25
	)
	action_tween.chain().set_parallel(true)
	action_tween.tween_property(
		sprite, "position:y", base_position.y - 1.5, MOVE_DURATION * 0.25
	)
	action_tween.tween_property(
		sprite, "rotation", 0.018 * signf(direction), MOVE_DURATION * 0.25
	)
	action_tween.chain().set_parallel(true)
	action_tween.tween_property(
		sprite, "position:y", base_position.y, MOVE_DURATION * 0.25
	)
	action_tween.tween_property(sprite, "rotation", 0.0, MOVE_DURATION * 0.25)


func _play_attack(direction: float) -> void:
	var facing: float = signf(direction) if not is_zero_approx(direction) else 1.0
	var anticipation: Vector2 = Vector2(-3.0 * facing, 1.0)
	var impact: Vector2 = Vector2(12.0 * facing, -1.5)
	action_tween = create_tween()
	action_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	action_tween.set_parallel(true)
	action_tween.tween_property(
		sprite, "position", base_position + anticipation, ATTACK_DURATION * 0.25
	)
	action_tween.tween_property(
		sprite, "rotation", -0.045 * facing, ATTACK_DURATION * 0.25
	)
	action_tween.chain().set_parallel(true)
	action_tween.set_ease(Tween.EASE_OUT)
	action_tween.tween_property(
		sprite, "position", base_position + impact, ATTACK_DURATION * 0.32
	)
	action_tween.tween_property(
		sprite, "rotation", 0.055 * facing, ATTACK_DURATION * 0.32
	)
	action_tween.chain().set_parallel(true)
	action_tween.set_ease(Tween.EASE_IN_OUT)
	action_tween.tween_property(
		sprite, "position", base_position + impact * 0.78, ATTACK_DURATION * 0.14
	)
	action_tween.tween_property(
		sprite, "rotation", 0.035 * facing, ATTACK_DURATION * 0.14
	)
	action_tween.chain().set_parallel(true)
	action_tween.tween_property(
		sprite, "position", base_position, ATTACK_DURATION * 0.29
	)
	action_tween.tween_property(sprite, "rotation", 0.0, ATTACK_DURATION * 0.29)


func play_frame_sequence(
	animation_name: String, duration: float, generation: int
) -> void:
	var frames: Array = frame_sequences.get(animation_name, []) as Array
	if frames.is_empty():
		await get_tree().create_timer(duration, false).timeout
	else:
		var frame_duration: float = duration / float(frames.size())
		for frame: Texture2D in frames:
			if generation != playback_generation or not is_instance_valid(sprite):
				return
			_crossfade_to_texture(frame, frame_duration * 0.68)
			await get_tree().create_timer(frame_duration, false).timeout
	if generation == playback_generation and is_instance_valid(sprite):
		_finish_action(animation_name)


func _play_hit() -> void:
	action_tween = create_tween()
	action_tween.tween_property(sprite, "modulate", Color(1.0, 0.28, 0.22, 1.0), 0.05)
	action_tween.tween_property(sprite, "modulate", base_modulate, 0.10)
	action_tween.finished.connect(_finish_action.bind(HIT))


func _play_death() -> void:
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(sprite, "modulate:a", 0.0, 0.22)
	action_tween.tween_property(sprite, "scale", base_scale * 0.82, 0.22)
	action_tween.finished.connect(_finish_action.bind(DEATH))


func _finish_action(completed_animation: String) -> void:
	animation_finished.emit(completed_animation)
	if completed_animation != DEATH:
		_restore_visual()
		current_animation = IDLE
		_apply_state_texture(IDLE)


func _apply_state_texture(animation_name: String) -> void:
	if sprite == null:
		return
	var fallback: Texture2D = base_texture
	sprite.texture = state_textures.get(animation_name, fallback) as Texture2D


func _crossfade_to_texture(texture: Texture2D, duration: float) -> void:
	if sprite.texture == texture:
		return
	if blend_tween != null and blend_tween.is_valid():
		blend_tween.kill()
	blend_sprite.texture = sprite.texture
	blend_sprite.position = sprite.position
	blend_sprite.scale = sprite.scale
	blend_sprite.rotation = sprite.rotation
	blend_sprite.modulate = base_modulate
	blend_sprite.visible = true
	sprite.texture = texture
	sprite.modulate = Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.0)
	blend_tween = create_tween().set_parallel(true)
	blend_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	blend_tween.tween_property(sprite, "modulate:a", base_modulate.a, duration)
	blend_tween.tween_property(blend_sprite, "modulate:a", 0.0, duration)
	blend_tween.finished.connect(_finish_crossfade)


func _finish_crossfade() -> void:
	if blend_sprite != null:
		blend_sprite.visible = false
	if sprite != null:
		sprite.modulate = base_modulate


func _sync_blend_sprite_transform() -> void:
	if sprite == null or blend_sprite == null or not blend_sprite.visible:
		return
	blend_sprite.position = sprite.position
	blend_sprite.scale = sprite.scale
	blend_sprite.rotation = sprite.rotation


func _restore_visual() -> void:
	if sprite == null:
		return
	if blend_tween != null and blend_tween.is_valid():
		blend_tween.kill()
	if blend_sprite != null:
		blend_sprite.visible = false
	sprite.position = base_position
	sprite.scale = base_scale
	sprite.modulate = base_modulate
	sprite.rotation = 0.0
