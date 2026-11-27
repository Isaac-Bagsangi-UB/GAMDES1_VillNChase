extends TextureButton

func _ready() -> void:
	toggle_mode = true
	set_pressed_no_signal(get_window().mode == Window.MODE_FULLSCREEN)
	toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
