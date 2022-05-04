extends Node
class_name HealthPool


# Signals
signal health_changed(new_health)
signal health_reached_zero


# Instance variables
export (int) var maximum_health = 100
export (int) var health_regeneration = 1
export (int) var health_regeneration_cutoff = 10
var current_health: int setget set_health


# Called when the node enters the scene tree for the first time.
func _ready():
	self.current_health = self.maximum_health


# Called every frame.
func _process(_delta: float) -> void:
	pass


func set_health(new_health: int) -> void:
	# Compute new health
	new_health = int(clamp(new_health, 0, self.maximum_health))
	# Did it change?
	if current_health != new_health:
		emit_signal("health_changed", new_health)
	# Apply new health
	current_health = new_health
	# Did this run out of health?
	if current_health == 0:
		emit_signal("health_reached_zero")


func _on_RegenTimer_timeout() -> void:
	if self.current_health >= self.health_regeneration_cutoff:
		return

	self.current_health += self.health_regeneration
