class_name SpeedPotion
extends PickableItem

const BLINK_TIME := 5.0 # seconds left when the Speed sprite starts blinking

func _init() -> void:
	item_id = "speed"

func use() -> void:
	var player := held_by
	player.clear_slot()
	player.speed_mult = 2.0
	var effect_sprite: CanvasItem = player.get_node("Speed")
	effect_sprite.modulate.a = 1.0
	effect_sprite.visible = true
	hide()
	set_process(false)
	$DrinkPotion.play()
	print("fast")

	# Split the effect into a normal phase and a blinking phase
	var total: float = $Effect.wait_time
	var blink_time: float = min(BLINK_TIME, total)
	var normal_time: float = total - blink_time
	$Effect.one_shot = true
	if normal_time > 0.0:
		$Effect.start(normal_time)
		await $Effect.timeout

	#blink effect
	var blink: Tween = null
	if is_instance_valid(effect_sprite):
		blink = effect_sprite.create_tween().set_loops()
		blink.tween_property(effect_sprite, "modulate:a", 0.2, 0.15)
		blink.tween_property(effect_sprite, "modulate:a", 1.0, 0.15)

	$Effect.start(blink_time)
	await $Effect.timeout

	if blink:
		blink.kill()
	if is_instance_valid(player):
		effect_sprite.modulate.a = 1.0
		effect_sprite.visible = false
		player.speed_mult = 1.0
	print("slow")
	queue_free()
