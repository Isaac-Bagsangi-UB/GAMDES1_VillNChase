class_name Gloves
extends PickableItem

var durability := 2   # how many successful punches before they break
var punch_hit := false
var damaged := false  # true once the sprite has been swapped to the damaged look

# The sprite shown after the first successful hit
var damaged_texture = preload("res://Custom assets/gloves_damaged.png")  # <- change this path


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
		elif not damaged:
			damaged = true
			update_sprite(player)


# Swaps the gloves' picture to the damaged version
func update_sprite(player) -> void:
	# pangpalit lang ng sprite
	var world_sprite = get_node_or_null("Sprite2D")
	if world_sprite and world_sprite.texture:
		# SIZE FIX: keep the on-screen size the same even if the damaged PNG has
		# different pixel dimensions than the original, so it doesn't blow up
		var old_size: Vector2 = world_sprite.texture.get_size()
		var new_size: Vector2 = damaged_texture.get_size()
		world_sprite.texture = damaged_texture
		world_sprite.scale *= old_size / new_size
