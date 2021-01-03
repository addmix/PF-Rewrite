extends Node

const path : String = "res://assets/particles/"

func load_particles() -> void:
	#init directory to path with all particles
	var dir := Directory.new()
# warning-ignore:return_value_discarded
	dir.open(path)
	
# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)
	var value = dir.get_next()
	
	#loop through all files
	while value != "":
		var res = load(path + "/" + value)
		var particle = Particles.new()
		particle.process_material = res
		particle.set_one_shot(true)
		
		value = dir.get_next()
