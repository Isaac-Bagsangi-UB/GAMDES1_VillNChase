class_name Mob
extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@export var max_health := 1
@export var SPEED := 100.0
@export var health := 1
@export var komsg := ""
@export var awakemsg := ""
@export var damage := 0
var direction = 1
var knocked_out := false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body):
	if "Player" in body.name:
		body.take_damage(damage, global_position.x)

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
	print(komsg)
	rotation_degrees = 90
	sprite.global_rotation = 0
	$"AnimatedSprite2D".play("knocked_out")
	$Hitbox.set_deferred("monitoring", false)
	$KOTimer.start()
	set_collision_layer_value(1, false)
	set_collision_layer_value(8, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(8, true)

func _on_ko_timer_timeout() -> void:
	knocked_out = false
	health = max_health
	rotation_degrees = 0
	sprite.rotation = 0
	position.y -= 8 
	$"AnimatedSprite2D".play("default")
	$Hitbox.set_deferred("monitoring", true)
	print(awakemsg)
	set_collision_layer_value(1, true)
	set_collision_layer_value(8, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(8, false)
func _physics_process(delta: float) -> void:
	gravity(delta)
	if knocked_out:
		velocity.x = 0
	else:
		reverse_direction()
		platform_edge()
		move_enemy()
	move_and_slide()
