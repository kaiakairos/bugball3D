extends Node2D

var velocities :Array[float]= []

var tick :int= 0

var bumpin = false

@export var partPos := Vector2.ZERO

func _process(delta):
	if !bumpin:
		tick += 1 + int(modulate != Color.WHITE)
	var letters = get_children()
	for l in range(letters.size()):
		var letter = letters[l]
		velocities[l] += 20.0 * delta
		letter.position.y = min(0.0,letter.position.y + velocities[l])
		
		if !bumpin:
			letter.offset.y = sin((tick*0.1) - l + position.y) * (2.0+ int(modulate != Color.WHITE))
		
func _ready():
	
	for l in get_children():
		velocities.append(0.0)

func bump():
	if bumpin:
		return
	bumpin = true
	for l in range(velocities.size()):
		velocities[l] = -3
		await get_tree().create_timer(0.035).timeout
	bumpin = false
	await get_tree().create_timer(0.25).timeout
	return
