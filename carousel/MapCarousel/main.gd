extends Control

# Gives the first card keyboard/gamepad focus so arrows work immediately.
func _ready() -> void:
	$HBox/Scroll/Cards/Card1/Background/Margin/VBox/Rows/EasyRow/EasyButton.grab_focus()
