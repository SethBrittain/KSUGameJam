extends Area2D

onready var player = get_parent().get_node("Player")

func _process(delta):
	$Hand.look_at(player.global_position)
	$PlayerLOS.cast_to = player.global_position-self.global_position
