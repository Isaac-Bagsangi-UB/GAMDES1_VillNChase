extends CanvasLayer

func _ready():
	$Menu.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused == true:
			get_tree().paused = false
			$Menu.hide()
			
		else:
			$Menu.show()
			get_tree().paused = true

func _on_continue_pressed():
	$Menu.hide()
	get_tree().paused = false


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
