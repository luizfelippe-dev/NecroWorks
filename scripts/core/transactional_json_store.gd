class_name TransactionalJsonStore
extends RefCounted


const TEMP_SUFFIX: String = ".tmp"
const BACKUP_SUFFIX: String = ".bak"


static func save_dictionary(payload: Dictionary, path: String) -> Error:
	if payload.is_empty() or path.is_empty():
		return ERR_INVALID_DATA
	var encoded: String = JSON.stringify(payload, "\t")
	if encoded.is_empty():
		return ERR_INVALID_DATA

	var temporary_path: String = path + TEMP_SUFFIX
	var backup_path: String = path + BACKUP_SUFFIX
	_remove_if_present(temporary_path)
	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(encoded)
	file.flush()
	var write_error: Error = file.get_error()
	file = null
	if write_error != OK:
		_remove_if_present(temporary_path)
		return write_error
	if load_dictionary(temporary_path).is_empty():
		_remove_if_present(temporary_path)
		return ERR_INVALID_DATA

	var absolute_path: String = ProjectSettings.globalize_path(path)
	var absolute_temporary: String = ProjectSettings.globalize_path(temporary_path)
	var absolute_backup: String = ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(path):
		if not load_dictionary(path).is_empty():
			var remove_error: Error = _remove_if_present(backup_path)
			if remove_error != OK:
				_remove_if_present(temporary_path)
				return remove_error
			var backup_error: Error = DirAccess.rename_absolute(
				absolute_path, absolute_backup
			)
			if backup_error != OK:
				_remove_if_present(temporary_path)
				return backup_error
		else:
			var corrupt_remove_error: Error = _remove_if_present(path)
			if corrupt_remove_error != OK:
				_remove_if_present(temporary_path)
				return corrupt_remove_error

	var replace_error: Error = DirAccess.rename_absolute(
		absolute_temporary, absolute_path
	)
	if replace_error != OK:
		if FileAccess.file_exists(backup_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(absolute_backup, absolute_path)
		_remove_if_present(temporary_path)
		return replace_error
	return OK


static func load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return {}
	return (parser.data as Dictionary).duplicate(true)


static func delete_family(path: String) -> Error:
	var first_error: Error = OK
	for candidate: String in [path, path + TEMP_SUFFIX, path + BACKUP_SUFFIX]:
		var error: Error = _remove_if_present(candidate)
		if first_error == OK and error != OK:
			first_error = error
	return first_error


static func _remove_if_present(path: String) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
