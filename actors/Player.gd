extends KinematicBody2D
class_name Player


# Instance variables
var last_update_time: int = 0
onready var health_pool: HealthPool = $HealthPool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func serialize() -> Dictionary:
	return {
		"pos": self.global_position,
		"rot": self.rotation,
		"hp": self.health_pool.serialize()
	}


func update_with_state(state: Dictionary) -> void:
	# Ignore older / duplicate update events
	if state["time"] <= self.last_update_time:
		return
	
	self.global_position = state["pos"]
	self.rotation = state["rot"]
