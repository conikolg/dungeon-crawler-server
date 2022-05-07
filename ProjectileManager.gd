extends Node


var fireball_scene: PackedScene = preload("res://projectiles/Fireball.tscn")
var projectile_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func spawn_fireball(client_id: int, position: Vector2, rotation: float) -> void:
	var fireball_instance = self.fireball_scene.instance()
	fireball_instance.client_id = client_id
	fireball_instance.global_position = position
	fireball_instance.rotation = rotation
	fireball_instance.name = "Fireball%d" % self.projectile_id
	self.projectile_id += 1
	self.add_child(fireball_instance)


func serialize_projectiles() -> Dictionary:
	var projectile_states: Dictionary = {}
	for child in self.get_children():
		projectile_states[child.name] = child.serialize()
	return projectile_states
