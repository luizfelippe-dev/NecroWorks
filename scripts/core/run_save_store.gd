class_name RunSaveStore
extends RefCounted


const SAVE_VERSION: int = 1
const DEFAULT_PATH: String = "user://necroworks_run.json"


static func has_checkpoint(path: String = DEFAULT_PATH) -> bool:
	return not load_checkpoint(path).is_empty()


static func save_checkpoint(
	state: Dictionary,
	path: String = DEFAULT_PATH
) -> Error:
	if state.is_empty():
		return ERR_INVALID_DATA

	var payload: Dictionary = state.duplicate(true)
	payload["save_version"] = SAVE_VERSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	return OK


static func load_checkpoint(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}

	var state: Dictionary = parsed
	if int(state.get("save_version", -1)) != SAVE_VERSION:
		return {}
	if int(state.get("wave", 0)) < 1:
		return {}
	return state


static func delete_checkpoint(path: String = DEFAULT_PATH) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
