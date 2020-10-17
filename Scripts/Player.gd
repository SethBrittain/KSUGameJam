extends KinematicBody2D

const MAX_SPEED = 1200
export (int) var speed
var Velocity = Vector2()
export (float) var drag

var posArray = [Vector2(0,0),Vector2(0,0)]

func _process(delta):
	if Input.is_action_pressed("move_left"):
		Velocity.x -= speed * delta
	if Input.is_action_pressed("move_right"):
		Velocity.x += speed * delta
	if Input.is_action_pressed("move_up"):
		Velocity.y -= speed * delta
	if Input.is_action_pressed("move_down"):
		Velocity.y += speed * delta
	
	Velocity *= drag
	if abs(Velocity.x) < 2:
		Velocity.x = 0
	if abs(Velocity.y) < 2:
		Velocity.y = 0

	if Velocity.length() > MAX_SPEED:
		Velocity = Velocity.normalized() * MAX_SPEED

	Velocity = move_and_slide(Velocity, Vector2(0,-1))
