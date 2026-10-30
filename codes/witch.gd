extends CharacterBody2D

@export var max_health := 1
var health := max_health
var knocked_out := false

func _on_hitbox_body_entered(body):
	pass

func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func _physics_process(delta: float) -> void:
	gravity(delta)
	if knocked_out:
		velocity.x = 0  # stays put but gravity still works
	move_and_slide()

func take_damage(damage: int, source_x = null) -> void:
	if knocked_out:
		return
	health -= damage
	if health <= 0:
		KnockOut()

func KnockOut() -> void:
	knocked_out = true
	velocity = Vector2.ZERO
	print("witch knocked out")
	$"mob collision".set_deferred("monitoring", false)
	$KOTimer.start()

func _on_ko_timer_timeout() -> void:
	knocked_out = false
	health = max_health
	$"mob collision".set_deferred("monitoring", true)
	print("witch is conscious")
