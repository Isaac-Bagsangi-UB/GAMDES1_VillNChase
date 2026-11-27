class_name HealthPotion
extends PickableItem


func _init() -> void:
	item_id = "health"


func use() -> void:
	if held_by.health > 0 and held_by.health < 10:
		if held_by.health == 9:
			held_by.health += 1
		else:
			held_by.health += 2
		held_by.update_hearts()
		held_by.clear_slot()
		$DrinkPotion.play()
		print(held_by.health)
		queue_free()
