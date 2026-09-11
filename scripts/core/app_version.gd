class_name AppVersion
extends RefCounted


const NUMBER: String = "0.6.1"
const DISPLAY: String = "v" + NUMBER
const WINDOWS: String = "0.6.1.0"


static func checkpoint_label() -> String:
	return NUMBER
