extends INumberGenerator
class_name ConstantNumberGenerator

@export var number: int

func _init(n = 0):
	number = n

func generate_int() -> int:
	return number
