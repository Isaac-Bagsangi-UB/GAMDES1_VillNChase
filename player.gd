extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -500.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump. and is_on_floor()
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

var player_health = 100 
var player_name = "Kuya Ben"
var enemy_health = 100
var enemy_name = "Ate Abigail"
var round = 0;

func _ready():
	round+=1
	print(player_name , " has entered the scene with " , player_health , " HP") 
	print(enemy_name , " has entered the scene with " , enemy_health , " HP") 
	take_damage(20)
	heal_HP(20)
	round+=1
	take_damage(100)
	
func take_damage(amount):
	player_health -= amount
	print(enemy_name, " has attacked. You have been damaged!")
	output_HP(player_health)
	checkPlayerHP(player_health)

func heal_HP(amount):
	player_health += amount
	print("You healed")
	output_HP(player_health)
	
func checkPlayerHP(player_health):
	if player_health <= 0:
		print("You have died")
	
func output_HP(player_health):
	print("Your health is now " , player_health)
