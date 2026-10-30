extends Area2D

var can_P = true
var player = null


func _physics_process(delta):
	if not can_P or not monitoring:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			petrify(body)
			break


func petrify(body):
	$AnimatedSprite2D.play("polymorph_casted") 
	player = body
	can_P = false
	player.can_move = false
	$Polymorphed.play() # SOUND: polymorph
	$P_time.start()
	$Cooldown.start()
	print("polymorphed")


func _on_p_time_timeout():
	$AnimatedSprite2D.play("default")
	if player:
		player.can_move = true
		player = null
	print("done with polymorph")


func _on_cooldown_timeout():
	can_P = true
