extends AnimatedSprite2D

func _ready():
	frame = 0
	play("default")


func _on_animation_finished():
	queue_free()
