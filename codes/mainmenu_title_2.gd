extends TextureRect

var tween: Tween
var target_x: float

func _ready():
	target_x = position.x
	position.x = target_x - 4000  # start off to the left

	tween = create_tween()
	tween.tween_property(self, "position:x", target_x, 5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func _input(event):
	var skip = (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventJoypadButton and event.pressed)
	if skip and tween and tween.is_running():
		tween.kill()
		position.x = target_x
