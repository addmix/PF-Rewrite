extends Node

func _ready() -> void:
	var ints := get_random_ints(1000)
	branchless_exclude_by_value(ints, 9)
	exclude_by_value(ints, 9)

static func get_random_ints(amount : int) -> Array:
	var array := []
	
	for i in range(amount):
		array.append(randi() % 10)
	
	return array

#this is slower than the non-branchless variant
static func branchless_exclude_by_value(input : Array, exclude) -> Array:
	#count objects to exclude
	var exclude_count := 0
	for i in range(input.size()):
		exclude_count += int(input[i] == exclude)
	
	#final array we will return
	var selection := []
	selection.resize(input.size() - exclude_count)
	
	var index := 0
	
	#we will advance the recursive index each time we meet an excluded value
	for i in range(input.size()):
		#only advance to next index when value is not excluded
		selection[index] = input[i]
		#advance assignment index if it isnt an excluded value
		index += int(input[i] != exclude)
	
	return selection

static func exclude_by_value(input : Array, exculde) -> Array:
	var selection := []
	
	for i in range(input.size()):
		if input[i] != exculde:
			selection.append(input[i])
	
	return selection
