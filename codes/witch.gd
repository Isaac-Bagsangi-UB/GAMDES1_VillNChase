extends CharacterBody2D

@export var max_health := 1
@export var despawn_delay := 3.0   # seconds after KO before sinking starts
@export var sink_time := 1.5       # how long the absorb animation takes
@export var sink_depth := 16.0     # pixels to sink into the ground
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
	sprite.play("knocked_out")
	set_collision_layer_value(1, false)
	set_collision_layer_value(8, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(8, true)

	var tween := create_tween()
	tween.tween_interval(despawn_delay)
	tween.tween_callback(_begin_sink)
	tween.tween_property(self, "global_position:y", sink_depth, sink_time).as_relative()
	tween.parallel().tween_property(self, "modulate:a", 0.0, sink_time)
	tween.tween_callback(queue_free)

func _begin_sink() -> void:
	set_physics_process(false)
	set_collision_layer_value(8, false)
	set_collision_mask_value(8, false)
