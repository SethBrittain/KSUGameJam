extends Area2D

func _on_Meat_body_entered(body):
	if body.name == "Player":
		if body.health <= 350:
			body.health += 150
		else:
			body.health = 500
		queue_free()
