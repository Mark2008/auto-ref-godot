extends Node
class_name OtherComponent

@export var some_component: SomeComponent

func _ready() -> void:
	assert(some_component)
	some_component.say_name()
