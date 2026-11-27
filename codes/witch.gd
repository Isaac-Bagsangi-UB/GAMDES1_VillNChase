extends CharacterBody2D

@export var max_health := 1
var health := max_health
var knocked_out := false
@onready var sprite: AnimatedSprite2D = $"mob collision/AnimatedSprite2D"

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
	rotation_degrees = 90
	sprite.global_rotation = 0
	$"mob collision".set_deferred("monitoring", false)
	$KOTimer.start()
	$"mob collision/AnimatedSprite2D".play("knocked_out")
	set_collision_layer_value(1, false)
	set_collision_layer_value(8, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(8, true)

func _on_ko_timer_timeout() -> void:
	knocked_out = false
	health = max_health
	rotation_degrees = 0
	position.y -= 8 
	$"mob collision".set_deferred("monitoring", true)
	print("witch is conscious")
	$"mob collision/AnimatedSprite2D".play("default")
	set_collision_layer_value(1, true)
	set_collision_layer_value(8, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(8, false)
