extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -875.0
var dead = false



func _physics_process(delta: float) -> void:
	
	movement(delta)
	gravity(delta)
	move_and_slide()

var health = 1

func _ready():
	pass
	
func take_damage(damage:int):
	health -= damage
	if health <= 0: 
		health = 0
		print("player died")
		
func movement(delta):
		# Handle jump. and is_on_floor()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY + (100*delta)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		if Input.is_action_pressed("ui_right"):
			$AnimatedSprite2D.play("walk") 
			$AnimatedSprite2D.flip_h = direction < 1
		if Input.is_action_pressed("ui_left"):
			$AnimatedSprite2D.play("walk") 
			$AnimatedSprite2D.flip_h = direction < 0
		
		if not is_on_floor():
			velocity.x /= 1.25 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.stop()
		
func gravity(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30
	
	if position.y > 900:
		take_damage(1)
