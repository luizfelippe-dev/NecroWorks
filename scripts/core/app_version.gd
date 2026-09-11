class_name AppVersion
extends RefCounted


const NUMBER: String = "0.6.2"
const DISPLAY: String = "v" + NUMBER
const WINDOWS: String = "0.6.2.0"


static func checkpoint_label() -> String:
	return NUMBER
