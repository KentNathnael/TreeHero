extends Node

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := "1.0"

func save_state(state: Dictionary) -> void:
	print("[SAVE] called. keys=", state.keys())
	print("[SAVE] path:", OS.get_user_data_dir(), "/savegame.json")
	state["meta"] = {
		"version": SAVE_VERSION,
		"timestamp_unix": Time.get_unix_time_from_system()
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(state, "\t")) # pretty biar gampang debug
	file.close()

func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# --- Helpers: Enum keys (int) aman di JSON ---
func encode_items(items: Dictionary) -> Dictionary:
	var out := {}
	for k in items.keys():
		out[str(k)] = items[k]
	return out

func decode_items(items: Dictionary) -> Dictionary:
	var out := {}
	for k in items.keys():
		out[int(k)] = int(items[k])
	return out

func v2i_to_dict(v: Vector2i) -> Dictionary:
	return {"x": v.x, "y": v.y}

func dict_to_v2i(d: Dictionary) -> Vector2i:
	return Vector2i(int(d.get("x", 0)), int(d.get("y", 0)))
