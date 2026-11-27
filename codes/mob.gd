class_name Mob
extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@export var max_health := 1
@export var SPEED := 100.0
@export var health := 1
@export var komsg := ""
@export var damage := 0


#despawn feature
@export var despawn_delay := 3.0
@export var sink_time := 1.5
@export var sink_depth := 16.0


var direction = 1
var knocked_out := false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	# ▼▼▼ ADDED ▼▼▼
	# the player and this mob ignore each other's body collision,
	# so the player can't push the mob (the Hitbox Area2D still deals damage)
	await get_tree().process_frame # wait a frame so the player exists
	for p in get_tree().get_nodes_in_group("Player"):
		if p is PhysicsBody2D: # skip other nodes in the group (e.g. the tutorial node)
			add_collision_exception_with(p)
			p.add_collision_exception_with(self)
	# ▲▲▲ END ADDED ▲▲▲

func _on_hitbox_body_entered(body):
	if "Player" in body.name:
		body.take_damage(damage, global_position.x)

func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30

func move_enemy():
	velocity.x = SPEED * direction

func platform_edge():
	if is_on_floor() and not is_on_wall() and not $RayCast2D.is_colliding():
		direction = -direction
		$AnimatedSprite2D.flip_h = direction < 0
		$RayCast2D.position.x = abs($RayCast2D.position.x) * direction
		$RayCast2D.force_raycast_update()

func reverse_direction():
	if is_on_wall():
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
	#lets the floor absorb body by disablin physics and collision
	set_physics_process(false)
	set_collision_layer_value(8, false)
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
