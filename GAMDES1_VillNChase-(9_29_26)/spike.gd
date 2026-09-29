extends Area2D

func _ready() -> void:
	pass 
	
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body):
	if "Player" in body.name:
		body.take_damage(1)
