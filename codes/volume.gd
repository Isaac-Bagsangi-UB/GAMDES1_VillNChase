extends TextureButton

func _ready() -> void:
	toggle_mode = true
	button_pressed = AudioServer.is_bus_mute(0)
	toggled.connect(_on_toggled)

func _on_toggled(is_muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), is_muted)
