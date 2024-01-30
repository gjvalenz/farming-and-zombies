extends Area2D
class_name PickupBoxComponent

signal on_received

func _ready():
	pass


func _process(delta):
	pass

func receive(item_name: String) -> void:
	on_received.emit(item_name)
