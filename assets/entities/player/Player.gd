extends KinematicBody

#general data
export var player_name := "Player"
export var id := -1
export var team := -1

#in game data
export var health := 100
export var weapons := []

#nodes
onready var RotationHelper : Spatial = $Smoothing/RotationHelper
onready var Head : Spatial = $Smoothing/RotationHelper/Head

#control finess
export var camera_max_angle := 85
export var camera_min_angle := -80

func _unhandled_input(event):
	if is_network_master():
		#mouse movement
		if event is InputEventMouseMotion:
			RotationHelper.rotate_y(deg2rad(event.relative.x))
			
			#branchless way of limiting up/down movement
			Head.rotation_degrees.x = ((Head.rotation_degrees.x - event.relative.y) * int(!Head.rotation_degrees.x - event.relative.y <= camera_min_angle and !Head.rotation_degrees.x - event.relative.y >= camera_max_angle)
			+ camera_min_angle * int(Head.rotation_degrees.x - event.relative.y <= camera_min_angle)
			+ camera_max_angle * int(Head.rotation_degrees.x - event.relative.y >= camera_max_angle))
		

