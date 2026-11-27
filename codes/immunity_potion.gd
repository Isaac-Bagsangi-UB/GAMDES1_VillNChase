class_name ImmunityPotion
extends PickableItem

func _init() -> void:
	item_id = "immunity"

func use() -> void:
	var player := held_by
	player.clear_slot()
	player.health += 1000
	player.get_node("Immunity").visible = true
	hide()
	set_process(false)
	$Effect.start()
	$DrinkPotion.play()
	print("immune")
	await $Effect.timeout
	if is_instance_valid(player):
		player.health = 10
		player.get_node("Immunity").visible = false
	print("vincible")
	queue_free()
