extends CanvasLayer


func _ready() -> void:
	$Menu.hide()


func _input(event) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	var start_screen := get_tree().get_first_node_in_group("start_screen")
	if start_screen and start_screen.visible:
		return

	if get_tree().paused:
		get_tree().paused = false
		$Menu.hide()
	else:
		$Menu.show()
		get_tree().paused = true


func _on_continue_pressed() -> void:
	$Menu.hide()
	get_tree().paused = false


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
