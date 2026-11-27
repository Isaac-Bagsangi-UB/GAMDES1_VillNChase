class_name Gloves
extends PickableItem

var durability := 2   # how many successful punches before they break
var punch_hit := false


func _init() -> void:
	item_id = "gloves"


# Called by the player when "use" is pressed while these are active.
func use_item(player) -> void:
	if player.is_punching or not player.can_move:
		return
	player.is_punching = true
	punch_hit = false
	player.get_node("AnimatedSprite2D").play("villie_attack")


# Called by the player on every animation frame change.
func on_frame_changed(player) -> void:
	var sprite = player.get_node("AnimatedSprite2D")
	if sprite.animation != "villie_attack" or sprite.frame != 1 or punch_hit:
		return
	punch_hit = true

	var landed := false
	for body in player.get_node("PunchHitbox").get_overlapping_bodies():
		if body != player and body.has_method("take_damage"):
			body.take_damage(1)
			player.get_node("HitEnemy").play()
			landed = true

	if landed:
		durability -= 1
		if durability <= 0:
			player.clear_slot()
			queue_free()
