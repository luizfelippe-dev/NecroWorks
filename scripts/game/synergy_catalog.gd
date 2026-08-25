extends RefCounted


const RECYCLING_PLANT: String = "recycling_plant"
const SECOND_SHIFT: String = "second_shift"
const BONE_ASSEMBLY_LINE: String = "bone_assembly_line"
const OVERCLOCKED_OSSUARY: String = "overclocked_ossuary"
const MEAT_SHIELD_PROTOCOL: String = "meat_shield_protocol"
const CRIMSON_ASSEMBLY: String = "crimson_assembly"
const PHANTOM_CONDUIT: String = "phantom_conduit"
const DARK_REFINERY: String = "dark_refinery"
const SOUL_FOUNDRY: String = "soul_foundry"
const OSSUARY_BALLISTICS: String = "ossuary_ballistics"

const ALL_SYNERGIES: Array[String] = [
	RECYCLING_PLANT,
	SECOND_SHIFT,
	BONE_ASSEMBLY_LINE,
	OVERCLOCKED_OSSUARY,
	MEAT_SHIELD_PROTOCOL,
	CRIMSON_ASSEMBLY,
	PHANTOM_CONDUIT,
	DARK_REFINERY,
	SOUL_FOUNDRY,
	OSSUARY_BALLISTICS,
]


static func is_known(synergy_id: String) -> bool:
	return synergy_id in ALL_SYNERGIES


static func get_name_key(synergy_id: String) -> String:
	return "SYNERGY_" + synergy_id.to_upper() if is_known(synergy_id) else ""


static func get_description_key(synergy_id: String) -> String:
	return (
		"SYNERGY_" + synergy_id.to_upper() + "_DESC"
		if is_known(synergy_id)
		else ""
	)
