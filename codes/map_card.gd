@tool
extends PanelContainer

@export_file("*.tscn") var level: String = ""

@export var title: String = "MAP":
	set(value):
		title = value
		if is_node_ready():
			$Margin/VBox/Title.text = title

@export var preview: Texture2D:
	set(value):
		preview = value
		if is_node_ready() and preview:
			$Previewarea/Preview.texture = preview

@onready var _easy: TextureButton = $Margin/VBox/Easy
@onready var _medium: TextureButton = $Margin/VBox/Medium
@onready var _hard: TextureButton = $Margin/VBox/Hard
@onready var _action: TextureButton = $Margin/VBox/Action

var _difficulty_chosen := false


func _ready() -> void:
	$Margin/VBox/Title.text = title
	if preview:
		$Previewarea/Preview.texture = preview

	if Engine.is_editor_hint():
		return

	# Easy is the default selection.
	_medium.set_pressed_no_signal(false)
	_hard.set_pressed_no_signal(false)
	_easy.set_pressed_no_signal(true)
	_choose_difficulty(GameSettings.Difficulty.EASY)
	_refresh_checks()


# The only styling in this script: Action is locked and dimmed
# whenever no difficulty is chosen.
func _update_action_state() -> void:
	_action.disabled = not _difficulty_chosen
	_action.modulate = Color(1, 1, 1, 0.5) if _action.disabled else Color.WHITE


func _choose_difficulty(d) -> void:
	GameSettings.difficulty = d
	_difficulty_chosen = true
	_update_action_state()


# Godot may store the level as a uid:// string, but progress is saved
# with the res:// path, so convert before comparing.
func _level_path() -> String:
	if level.begins_with("uid://"):
		var id := ResourceUID.text_to_id(level)
		if ResourceUID.has_id(id):
			return ResourceUID.get_id_path(id)
	return level


func _refresh_checks() -> void:
	if level == "":
		return
	var path := _level_path()
	$"Margin/VBox/Easy/check(easy)".visible = GameSettings.is_completed(path, GameSettings.Difficulty.EASY)
	$"Margin/VBox/Medium/check(medium)".visible = GameSettings.is_completed(path, GameSettings.Difficulty.MEDIUM)
	$"Margin/VBox/Hard/check(hard)".visible = GameSettings.is_completed(path, GameSettings.Difficulty.HARD)


func _on_action_pressed() -> void:
	if not _difficulty_chosen:
		return
	get_tree().change_scene_to_file(level)


func _on_easy_pressed() -> void:
	_choose_difficulty(GameSettings.Difficulty.EASY)


func _on_medium_pressed() -> void:
	_choose_difficulty(GameSettings.Difficulty.MEDIUM)


func _on_hard_pressed() -> void:
	_choose_difficulty(GameSettings.Difficulty.HARD)
