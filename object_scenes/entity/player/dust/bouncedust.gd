extends CPUParticles2D

var tick :float= 0.0
@export var deleteMe := true

func _ready():
	emitting = true
	set_process(deleteMe)
	
func _process(delta):
	tick += 60 * delta
	
	if tick > 45.0:
		queue_free()
