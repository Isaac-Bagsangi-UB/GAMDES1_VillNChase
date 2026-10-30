extends Label

func _process(_delta):
	text = str(ceil($Timer.time_left))
