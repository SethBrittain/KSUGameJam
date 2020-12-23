extends KinematicBody2D

var b = preload("res://Scenes/Bullet.tscn")
onready var player = get_parent().get_parent().get_node("Player")
export (int) var speed
var states = ["idle","alert","engaging"]
var state
var Velocity = Vector2()
var can_see_player = false
var player_in_cone = false

onready var los_line = $PlayerLOS

func _ready():
	state = states[0]

func _process(delta):
	if speed > 0:
		$DetectionCone2.monitoring = false
		$DetectionCone.monitoring = true
	if speed < 0:
		$DetectionCone2.monitoring = true
		$DetectionCone.monitoring = false
	los_line.cast_to = player.global_position-self.global_position
	
	if abs(los_line.get_collision_point().distance_to(player.global_position)) <= 50:
		can_see_player = true
	else:
		can_see_player = false
		
	if state == "idle":
		Velocity.x = speed * delta
		Velocity.y = 100
		Velocity = move_and_slide(Velocity, Vector2(0,-1))
		
		if !$FloorDetectorRight.is_colliding():
			speed = -speed
			self.global_position.x -= 1
		if !$FloorDetectorLeft.is_colliding():
			speed = -speed
			self.global_position.x += 1
		if !$WallDetectorRight.is_colliding():
			speed = -speed
			self.global_position.x += 5
		if !$WallDetectorLeft.is_colliding():
			speed = -speed
			self.global_position.x -= 5
		
		if can_see_player and player_in_cone:
			state = states[1]
	
	elif state == "alert":
		if can_see_player:
			$AlertTimer.start()
			if $ShootTimer.is_stopped():
				$ShootTimer.start()
		$Hand.look_at(player.global_position)
		
func shoot(target_position):
	$Gunshot.pitch_scale = rand_range(0.85,1.15)
	$Gunshot.play()
	var B = b.instance()
	B.target_position = target_position
	B.global_position = $Hand/Muzzle.global_position
	B.start_pos = $Hand/Muzzle.global_position
	B.target_position = player.global_position
	get_parent().add_child(B)

func _on_DetectionCone_body_entered(body):
	if body.name == "Player":
		player_in_cone = true

func _on_DetectionCone2_body_entered(body):
	if body.name == "Player":
		player_in_cone = true

func _on_DetectionCone_body_exited(body):
	if body.name == "Player":
		player_in_cone = false

func _on_DetectionCone2_body_exited(body):
	if body.name == "Player":
		print("out cone")
		player_in_cone = false

func _on_AlertTimer_timeout():
	state = states[0]

func _on_ShootTimer_timeout():
	shoot($PlayerLOS.get_collision_point())


func _on_RockTimer_timeout():
	if abs(Velocity.x) > 1:
		$SoldierSprite.rotation_degrees = rand_range(-20,20)
	else:
		$SoldierSprite.rotation_degrees = 0
	
