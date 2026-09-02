extends Node


signal animation_started(animation_name: String)
signal animation_finished(animation_name: String)

const IDLE: String = "idle"
const MOVE: String = "move"
const ATTACK: String = "attack"
const HIT: String = "hit"
const DEATH: String = "death"
const SUPPORTED_ANIMATIONS: Array[String] = [IDLE, MOVE, ATTACK, HIT, DEATH]

var sprite: Sprite2D
var current_animation: String = IDLE
var base_position: Vector2
var base_scale: Vector2
var base_modulate: Color
var idle_time: float = 0.0
var action_tween: Tween
var reduced_motion: bool = false


func bind(target_sprite: Sprite2D) -> void:
	sprite = target_sprite
	base_position = sprite.position
	base_scale = sprite.scale
	base_modulate = sprite.modulate
	set_process(true)


func _process(delta: float) -> void:
	if reduced_motion or sprite == null or current_animation != IDLE:
		return
	idle_time += delta
	sprite.position.y = base_position.y + sin(idle_time * 3.2) * 1.4


func play(animation_name: String, direction: float = 1.0) -> bool:
	if sprite == null or animation_name not in SUPPORTED_ANIMATIONS:
		return false
	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual()
	current_animation = animation_name
	animation_started.emit(animation_name)
	if reduced_motion:
		_play_reduced_animation(animation_name)
		return true
	match animation_name:
		IDLE:
			_finish_action(IDLE)
		MOVE:
			_play_move(direction)
		ATTACK:
			_play_attack(direction)
		HIT:
			_play_hit()
		DEATH:
			_play_death()
	return true


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual()
	current_animation = IDLE
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
	action_tween.tween_property(sprite, "rotation", 0.035 * signf(direction), 0.08)
	action_tween.tween_property(sprite, "rotation", 0.0, 0.08)
	action_tween.finished.connect(_finish_action.bind(MOVE))


func _play_attack(direction: float) -> void:
	var offset: Vector2 = Vector2(10.0 * signf(direction), -1.0)
	action_tween = create_tween()
	action_tween.set_trans(Tween.TRANS_QUAD)
	action_tween.tween_property(sprite, "position", base_position + offset, 0.07)
	action_tween.tween_property(sprite, "position", base_position, 0.11)
	action_tween.finished.connect(_finish_action.bind(ATTACK))


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
		current_animation = IDLE


func _restore_visual() -> void:
	if sprite == null:
		return
	sprite.position = base_position
	sprite.scale = base_scale
	sprite.modulate = base_modulate
	sprite.rotation = 0.0
