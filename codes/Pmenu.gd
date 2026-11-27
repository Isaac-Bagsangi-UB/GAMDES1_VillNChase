extends Control	

func _ready():
	$Confirmation.hide()

func _on_to_main_pressed() -> void:
	$Confirmation.show()


func _on_no_pressed() -> void:
	$Confirmation.hide()
