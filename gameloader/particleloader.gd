extends Node

const path : String = "res://assets/particles/"

var particles := [
	"m4a1_muzzle_flash.tres",
]

var frame_count := 0
func _physics_process(delta : float) -> void:
	frame_count += 1
	if frame_count > 4:
		queue_free()

func load_particles() -> void:
	for particle in particles:
		var res = load(path + particle)
		var particles = Particles.new()
		particles.process_material = res
		particles.set_one_shot(true)
		
		self.add_child(particles)
		particles.emitting = true
