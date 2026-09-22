extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -1000.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30


	# Handle jump. and is_on_floor()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY + (100*delta)
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not is_on_floor():
			velocity.x /= 1.25 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

var health = 1

func _ready():
	pass
	
func take_damage(damage:int):
	health -= damage
	if health <= 0: 
		health = 0
		print("player died")
