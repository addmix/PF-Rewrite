extends Spatial

func _ready():
	if is_network_master():
		$metarig/Skeleton.set_bone_pose($metarig/Skeleton.find_bone("head"), Transform(Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)))
