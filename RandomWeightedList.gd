class_name RandomWeightedList

var elements: Array
var weights: Array[int]
var total_weight: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(p_elements: Array, p_weights: Array[int] = [], p_is_seeded: bool = false, p_seed: int = -1):
	assert(p_elements.size() >= 0)
	if p_weights.size() <= 0:
		p_weights = [1 * p_elements.size()]
	var least = p_weights.min()
	assert(least > 0)
	elements = p_elements
	weights = p_weights
	var summer = func(t, x): return t + x
	total_weight = weights.reduce(summer, 0)
	if not p_is_seeded:
		rng.randomize()
	else:
		rng.seed = p_seed

func add_element(e, w: int):
	elements.append(e)
	weights.append(w)
	total_weight += w
	
func remove_element(e) -> bool:
	var index: int = elements.find(e)
	if index == -1:
		return false
	total_weight -= weights[index]
	weights.remove_at(index)
	elements.remove_at(index)
	return true

func get_random():
	var rolled: int = rng.randi_range(0, total_weight)
	var subsum = 0
	for i in range(0, elements.size()):
		subsum += weights[i]
		if rolled <= subsum:
			return elements[i]
	return elements.back()
