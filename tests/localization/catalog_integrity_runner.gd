extends SceneTree


const CATALOG_PATH: String = "res://localization/ui.csv"
const LOCALES: Array[String] = ["en", "pt_BR", "es"]


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var file: FileAccess = FileAccess.open(CATALOG_PATH, FileAccess.READ)
	assert(file != null)
	var header: PackedStringArray = file.get_csv_line()
	assert(Array(header) == ["keys", "en", "pt_BR", "es"])
	var entries: Dictionary = {}
	while file.get_position() < file.get_length():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 1 and row[0].strip_edges().is_empty():
			continue
		assert(row.size() == 4)
		var key: String = row[0].strip_edges()
		assert(not key.is_empty())
		assert(key not in entries)
		for column: int in range(1, row.size()):
			assert(not row[column].strip_edges().is_empty())
		entries[key] = row
	file.close()
	assert(entries.size() >= 400)
	for locale_index: int in range(LOCALES.size()):
		TranslationServer.set_locale(LOCALES[locale_index])
		for key: String in entries:
			var expected: String = (
				(entries[key] as PackedStringArray)[locale_index + 1]
			).replace("\\n", "\n")
			var translated: String = TranslationServer.translate(key)
			assert(
				translated == expected,
				"Translation mismatch for %s/%s" % [key, LOCALES[locale_index]]
			)
	TranslationServer.set_locale(original_locale)
	print("LOCALIZATION CATALOG INTEGRITY: PASS (%d KEYS, 3 LOCALES)" % entries.size())
	quit()
