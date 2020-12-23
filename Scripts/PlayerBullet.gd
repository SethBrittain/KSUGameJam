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

func spawn_meat():
	var m = preload("res://Scenes/Meat.tscn")
	var M = m.instance()
	M.global_position = global_position
	get_parent().get_parent().add_child(M)

func _on_Bullet_body_entered(body):
	if body.get_parent().name == "Enemies":
		randomize()
		var e = randi() % 3 
		if e == 0:
			spawn_meat()
		body.queue_free()
