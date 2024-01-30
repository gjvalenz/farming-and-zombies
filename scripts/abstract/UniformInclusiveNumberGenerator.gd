extends INumberGenerator
class_name UniformInclusiveNumberGenerator

@export var min: int
@export var max: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func generate_int() -> int:
	assert(min <= max)
	return rng.randi_range(min, max)
