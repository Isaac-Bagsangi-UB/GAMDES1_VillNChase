extends TextureRect

var tween: Tween
var target_y: float

func _ready():
	target_y = position.y
	position.y = target_y - 400  # start above the final spot

	tween = create_tween()
	tween.tween_property(self, "position:y", target_y, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func _input(event):
	var skip = (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventJoypadButton and event.pressed)
	if skip and tween and tween.is_running():
		tween.kill()
		position.y = target_y
