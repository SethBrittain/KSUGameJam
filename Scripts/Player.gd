extends KinematicBody2D

var b = preload("res://Scenes/PlayerBullet.tscn")
var health = 500
var shot_count = 0

const MAX_SPEED = 1200
export (int) var speed
var Velocity = Vector2()
export (float) var drag
export (float) var leg_update_speed

onready var bullet_ind = $Bullets.get_children()

onready var front_check = $Sensors/FrontCheck
onready var back_check = $Sensors/BackCheck
onready var front_check2 = $Sensors/FrontCheck2
onready var back_check2 = $Sensors/BackCheck2
onready var top_check = $Sensors/TopCheck1
onready var top_check2 = $Sensors/TopCheck2

onready var leg_node1 = $Legs/LegNode.get_children()
onready var leg_node2 = $Legs/LegNode2.get_children()
onready var leg_node3 = $Legs/LegNode3.get_children()
onready var leg_node4 = $Legs/LegNode4.get_children()
onready var leg_node5 = $Legs/LegNode5.get_children()
onready var leg_node6 = $Legs/LegNode6.get_children()

export (float) var leg_sens_length
export var step_rate = 0.6
var time_since_last_step = 0
var cur_f_leg = 0
var cur_b_leg = 0
var cur_f_leg2 = 0
var cur_b_leg2 = 0
var cur_t_leg = 0
var cur_t_leg2 = 0
var use_front = false
var use_second_front = false
var use_second_back = false
var use_left_top = false

func _ready(): #on ready, updates length of rays 
	front_check.cast_to = Vector2(0,leg_sens_length)
	back_check.cast_to = Vector2(0,leg_sens_length)
	front_check2.cast_to = Vector2(leg_sens_length,0)
	back_check2.cast_to = Vector2(-leg_sens_length,0)
	front_check2.cast_to = Vector2(leg_sens_length,0)
	back_check2.cast_to = Vector2(-leg_sens_length,0)
	top_check.cast_to = Vector2(0,-leg_sens_length)
	top_check2.cast_to = Vector2(0,-leg_sens_length)
	
	#updates rays for the initial movement
	front_check.force_raycast_update()
	back_check.force_raycast_update()
	front_check2.force_raycast_update()
	back_check2.force_raycast_update()
	top_check.force_raycast_update()
	top_check2.force_raycast_update()
	
	#attatches legs to nearby surfaces on initialization
	for i in range(12):
		step()

func _physics_process(delta):
	if Input.is_action_just_pressed("fire") and shot_count > 0:
		shoot()
		bullet_ind[shot_count].visible = false
		shot_count -= 1
	
	if get_global_mouse_position().x < global_position.x:
		$PlayerSprite.flip_v = true
	else:
		$PlayerSprite.flip_v = false
	
	#general 2D movement
	if Input.is_action_pressed("move_down"):
		Velocity.y += speed * delta
	if Input.is_action_pressed("move_up"):
		Velocity.y -= speed * delta
	if Input.is_action_pressed("move_left"):
		Velocity.x -= speed * delta
	if Input.is_action_pressed("move_right"):
		Velocity.x += speed * delta
	
	#drag for deceleration
	Velocity *= drag
	
	#stops velocity from being tiny non-zero
	if abs(Velocity.x) < 2:
		Velocity.x = 0
	if abs(Velocity.y) < 2:
		Velocity.y = 0
		
	#stops diagonal movement being faster than horizontal
	if Velocity.length() > MAX_SPEED:
		Velocity = Velocity.normalized() * MAX_SPEED
	
	#moves player based on velocity
	Velocity = move_and_slide(Velocity, Vector2(0,-1))
	
func _process(delta): #updates the legs end position occasionaly
	$Bullets.get_children()
	$CanvasLayer/Control/Label.text = str(health) + " " + str(shot_count)
	$CanvasLayer/Control/Health.margin_right = 40 + health
	time_since_last_step += delta*leg_update_speed
	if time_since_last_step >= step_rate:
		time_since_last_step = 0
		step()
	self.look_at(get_global_mouse_position())

func step():
	var leg = null
	var sensor = null
	if use_front:
		if !use_second_front:
			leg = leg_node1[cur_f_leg]
			cur_f_leg += 1
			cur_f_leg %= leg_node1.size()
			sensor = front_check
			use_second_front = !use_second_front
		else:
			leg = leg_node3[cur_f_leg2]
			cur_f_leg2 += 1
			cur_f_leg2 %= leg_node3.size()
			sensor = front_check2
			use_second_front = !use_second_front
	else:
		if !use_second_back:
			leg = leg_node2[cur_b_leg]
			cur_b_leg += 1
			cur_b_leg %= leg_node2.size()
			sensor = back_check
			use_second_back = !use_second_back
		else:
			leg = leg_node4[cur_b_leg2]
			cur_b_leg2 += 1
			cur_b_leg2 %= leg_node4.size()
			sensor = back_check2
			use_second_back = !use_second_back
	use_front = !use_front
	
	var target = sensor.get_collision_point()
	leg.step(target)
	
	if use_left_top:
		leg = leg_node5[cur_t_leg]
		cur_t_leg += 1
		cur_t_leg %= leg_node5.size()
		sensor = top_check
		use_left_top = !use_left_top
	else:
		leg = leg_node6[cur_t_leg2]
		cur_t_leg2 += 1
		cur_t_leg2 %= leg_node6.size()
		sensor = top_check2
		use_left_top = !use_left_top
		
	target = sensor.get_collision_point()
	leg.step(target)

func shoot():
	var B = b.instance()
	B.target_position = get_global_mouse_position()
	B.global_position = global_position
	B.start_pos = global_position
	get_parent().add_child(B)
