extends Area2D
class_name Fireball


# Instance variables
export (int) var movement_speed = 35
export (int) var damage = 75

onready var despawn_timer = $DespawnTimer

var direction: Vector2 = Vector2.ZERO
var client_id: int


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_collision")
	self.despawn_timer.connect("timeout", self, "queue_free")


func _physics_process(_delta: float) -> void:
	var movement_dir: Vector2 = Vector2.RIGHT.rotated(self.rotation).normalized()
	self.global_position += movement_dir * self.movement_speed


func on_collision(body: Node) -> void:
	if body is Enemy:
		if "health_pool" in body:
			body.health_pool.current_health -= self.damage
		self.queue_free()


func serialize() -> Dictionary:
	return {
		"pos": self.global_position,
		"rot": self.rotation
	}
