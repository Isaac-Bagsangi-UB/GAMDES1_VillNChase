extends CanvasLayer

@onready var buttons = [$start, $volume, $fullscreen_button, $exit]

var tween: Tween
var skipped := false

func _ready():
	for b in buttons:
		b.modulate.a = 0.0
		b.disabled = true

	tween = create_tween()
	tween.tween_interval(4.0)  # initial wait
	for i in buttons.size():
		var t = tween if i == 0 else tween.parallel()
		t.tween_property(buttons[i], "modulate:a", 1.0, 0.8).set_delay(i * 0.3)  # staggered
	tween.finished.connect(_enable_buttons)

func _input(event):
	if skipped or not (tween and tween.is_running()):
		return
	var skip = (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventJoypadButton and event.pressed)
	if skip:
		skipped = true
		tween.kill()
		for b in buttons:
			b.modulate.a = 1.0
		# small delay so the same click/key doesn't instantly press a button
		await get_tree().create_timer(0.2).timeout
		_enable_buttons()

func _enable_buttons():
	for b in buttons:
		b.disabled = false

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
