extends Area2D

var start_pos = Vector2()
var target_position = Vector2()
var Velocity
var damage = 75
var speed = 1200

func _ready():
	self.global_position = start_pos
	var dist = target_position-start_pos
	Velocity = dist/dist.length()

func _process(delta):
	global_position += Velocity*speed*delta
	print(Velocity)

func _on_ExpiryTimer_timeout():
	self.queue_free()

func _on_Bullet_body_entered(body):
	if body.name != "Player":
		self.queue_free()
	else:
		body.health -= damage
		body.shot_count += 1
		body.bullet_ind[body.shot_count].visible = true
		if body.get_node("Bullets/Blood").emitting != true:
			 body.get_node("Bullets/Blood").emitting = true
		self.queue_free()
