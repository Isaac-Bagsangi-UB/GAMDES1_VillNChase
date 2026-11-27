class_name SpeedPotion
extends PickableItem

func _init() -> void:
	item_id = "speed"

func use() -> void:
	var player := held_by
	player.clear_slot()
	player.speed_mult = 2.0
	player.get_node("Speed").visible = true
	hide()
	set_process(false)
	$Effect.start()
	$DrinkPotion.play()
	print("fast")
	await $Effect.timeout
	if is_instance_valid(player):
		player.speed_mult = 1.0
		player.get_node("Speed").visible = false
	print("slow")
	queue_free()
