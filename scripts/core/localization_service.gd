class_name LocalizationService
extends RefCounted


const DEFAULT_LOCALE: String = "en"
const SUPPORTED_LOCALES: PackedStringArray = ["en", "pt_BR", "es"]


static func normalize_locale(locale: String) -> String:

	var standardized: String = TranslationServer.standardize_locale(locale)


	if standardized.begins_with("pt"):
		return "pt_BR"


	if standardized.begins_with("es"):
		return "es"


	if standardized.begins_with("en"):
		return "en"


	return DEFAULT_LOCALE


static func set_locale(locale: String) -> String:

	var normalized: String = normalize_locale(locale)
	TranslationServer.set_locale(normalized)
	return normalized


static func is_supported(locale: String) -> bool:

	return normalize_locale(locale) in SUPPORTED_LOCALES
