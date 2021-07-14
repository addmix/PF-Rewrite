extends Node

const path : String = "res://assets/particles/"

var particles := [
	"m4a1_muzzle_flash.tres",
]

var frame_count := 0

func _physics_process(_delta : float) -> void:
	frame_count += 1
	if frame_count > 4:
		queue_free()

func load_particles(args : Array = []) -> void:
	for particle in particles:
		var res = load(path + particle)
		var particles_instance = Particles.new()
		particles_instance.process_material = res
		particles_instance.set_one_shot(true)
		
		self.add_child(particles_instance)
		particles_instance.emitting = true
