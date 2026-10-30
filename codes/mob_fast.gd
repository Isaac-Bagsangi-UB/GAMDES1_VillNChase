extends CharacterBody2D

@export var max_health := 1
const SPEED = 100.0
var direction = 1
var health = 1
var knocked_out := false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body):
	if "Player" in body.name:
		body.take_damage(2, global_position.x)

func gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30

func move_enemy():
	velocity.x = SPEED * direction

func platform_edge():
	# skip when touching a wall, reverse_direction() already handled the turn
	if is_on_floor() and not is_on_wall() and not $RayCast2D.is_colliding():
		direction = -direction
		$AnimatedSprite2D.flip_h = direction < 0
		$RayCast2D.position.x = abs($RayCast2D.position.x) * direction
		$RayCast2D.force_raycast_update()

func reverse_direction():
	if is_on_wall():
		# face away from the wall instead of toggling, so it can't flip back
		direction = 1 if get_wall_normal().x > 0 else -1
		$AnimatedSprite2D.flip_h = direction < 0
		$RayCast2D.position.x = abs($RayCast2D.position.x) * direction
		$RayCast2D.force_raycast_update()

func take_damage(damage: int, source_x = null) -> void:
	if knocked_out:
		return
	health -= damage
	if health <= 0:
		KnockOut()

func KnockOut() -> void:
	knocked_out = true
	velocity = Vector2.ZERO
	print("fast boy is knocked out")
	$Hitbox.set_deferred("monitoring", false)
	$KOTimer.start()

func _on_ko_timer_timeout() -> void:
	knocked_out = false
	health = max_health
	$Hitbox.set_deferred("monitoring", true)
	print("fast boy is conscious")

func _physics_process(delta: float) -> void:
	gravity(delta)
	if knocked_out:
		velocity.x = 0
	else:
		reverse_direction()
		platform_edge()
		move_enemy()
	move_and_slide()
