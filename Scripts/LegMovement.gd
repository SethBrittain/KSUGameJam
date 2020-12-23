extends Position2D

const MIN_DISTANCE = 100

onready var joint1 = $Joint1
onready var joint2 = $Joint1/Joint2
onready var end = $Joint1/Joint2/End

var len1 = 1
var len2 = 1
var len3 = 1

export var flipped = true

var goal_pos = Vector2()
var int_pos = Vector2()
var start_pos = Vector2()
var step_height =  20
var step_rate = 0.1
var step_time = 0.0

func _ready():
	len1 = joint1.position.x
	len2 = joint2.position.x
	len3 = end.position.x

	if flipped:
		$Seg1.flip_h = true
		$Joint1/Seg2.flip_h = true
		$Joint1/Joint2/Seg3.flip_h = true

func _process(delta):
	step_time += delta
	var target_position = Vector2()
	var t = step_time/step_rate
	if t < 0.5:
		target_position = start_pos.linear_interpolate(int_pos, t / 0.5)
	elif t < 1.0:
		target_position = start_pos.linear_interpolate(goal_pos, (t - 0.5) / 0.5)
	else:
		target_position = goal_pos
	update_ik(target_position)

func step(g_pos):
	if goal_pos == g_pos:
		return
	
	goal_pos = g_pos
	var end_pos = end.global_position
	
	var height = goal_pos.y
	if end_pos.y < height:
		height = end_pos.y
	
	var mid = (goal_pos.x + end_pos.x) / 2.0
	start_pos = end_pos
	int_pos = Vector2(mid, height - step_height)
	step_time = 0.0
	get_parent().get_parent().get_parent().get_node("Gross").pitch_scale = rand_range(0.85,1.15)
	if !get_parent().get_parent().get_parent().get_node("Gross").playing:
		get_parent().get_parent().get_parent().get_node("Gross").play()

func update_ik(targ_pos):
	var offset = targ_pos - global_position
	var target_distance = offset.length()
	if target_distance < MIN_DISTANCE:
		offset = (offset / target_distance) * MIN_DISTANCE
		target_distance = MIN_DISTANCE
	
	var base_rot = offset.angle()
	var len_total = len1+len2+len3
	var invis_side_length = (len1+len2) * clamp(target_distance / len_total, 0.0, 1.0)
	
	var base_angles = sss(invis_side_length, len3, target_distance)
	var second_angles = sss(len1, len2, invis_side_length)
	
	self.global_rotation = base_angles.B + second_angles.B + base_rot
	joint1.rotation = second_angles.C
	joint2.rotation = base_angles.C + second_angles.A

func law_of_cosine(a, b, c):
	if 2*a*b == 0:
		return 0
	return acos((a*a + b*b - c*c) / (2*a*b))

func sss(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B":0, "C": 0}
	var angle_a = law_of_cosine(side_b, side_c, side_a)
	var angle_b = law_of_cosine(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b
	
	if flipped:
		angle_a = -angle_a
		angle_b = -angle_b
		angle_c = -angle_c
	
	return {"A": angle_a, "B": angle_b, "C": angle_c}
