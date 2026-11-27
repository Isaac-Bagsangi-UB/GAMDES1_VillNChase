extends Control

@onready var progress: ProgressBar = $Progress
@onready var cards: Node = $HBox/Cards

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _ready() -> void:
	progress.max_value = cards.get_child_count()
	for card in cards.get_children():
		card.visibility_changed.connect(update_progress, CONNECT_DEFERRED)
	update_progress()

func update_progress() -> void:
	var children := cards.get_children()
	for i in children.size():
		if children[i].visible:
			progress.value = i + 1
			return
