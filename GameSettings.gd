extends Node

enum Difficulty { EASY, MEDIUM, HARD }

var difficulty: Difficulty = Difficulty.EASY

const HEARTS := {
	Difficulty.EASY: 10,
	Difficulty.MEDIUM: 5,
	Difficulty.HARD: 3,
}

const TIME_LIMIT := {
	Difficulty.EASY: 600.0,
	Difficulty.MEDIUM: 400.0,
	Difficulty.HARD: 200.0,
}

const MASTER_VOLUME := 0.55

const SAVE_PATH := "user://progress.cfg"

# { "res://scenes/map1.tscn": { "EASY": true, "HARD": true } }
var completed := {}


func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(MASTER_VOLUME))
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		completed = cfg.get_value("progress", "completed", {})


func get_hearts() -> int:
	return HEARTS[difficulty]


func get_time_limit() -> float:
	return TIME_LIMIT[difficulty]


func mark_completed(level: String, diff: int) -> void:
	print("SAVING: ", level, " / ", Difficulty.keys()[diff])  # debug, remove later
	var key: String = Difficulty.keys()[diff]
	if not completed.has(level):
		completed[level] = {}
	completed[level][key] = true
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "completed", completed)
	cfg.save(SAVE_PATH)


func is_completed(level: String, diff: int) -> bool:
	return completed.get(level, {}).get(Difficulty.keys()[diff], false)
