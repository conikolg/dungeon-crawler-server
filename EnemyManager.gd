extends Node


# Instance variables
var enemy_scene: PackedScene = preload("res://actors/Enemy.tscn")
var enemy_max_count: int = 10
var enemy_unused_id: int = 0

var player_manager: Node = null

onready var enemy_spawn_timer = $EnemySpawnTimer
onready var enemy_container = $Enemies


func _ready():
	self.enemy_spawn_timer.connect("timeout", self, "spawn_enemy")


func _physics_process(_delta: float) -> void:
	self.assign_targets()


func spawn_enemy() -> void:
	if self.enemy_container.get_child_count() >= self.enemy_max_count:
		return
	
	var location: Vector2 = Vector2(randi() % 500, randi() % 500)
	var direction: float = Vector2.ZERO.angle_to_point(location)
	var enemy_id = self.enemy_unused_id
	self.enemy_unused_id += 1
	
	var enemy_node = self.enemy_scene.instance()
	enemy_node.name = str(enemy_id)
	enemy_node.global_position = location
	enemy_node.rotation = direction
	self.enemy_container.add_child(enemy_node)


func serialize_enemies() -> Dictionary:
	var enemy_states: Dictionary = {}
	for child in self.enemy_container.get_children():
		enemy_states[child.name] = child.serialize()
	return enemy_states


func hit_enemy(enemy_name: String) -> void:
	# Deal 50 damage to whoever was hit
	var child: Enemy = self.enemy_container.get_node_or_null(enemy_name)
	if child == null:
		return
	child.health_pool.current_health -= 50


func assign_targets() -> void:
	if self.player_manager == null:
		return
	
	if self.player_manager.get_child_count() == 0:
		return
	
	# Assign a random player as the target to all enemies with no target
	var players: Array = self.player_manager.get_children()
	for enemy_child in self.enemy_container.get_children():
		if enemy_child.target == null:
			var player_target = players[randi() % players.size()]
			enemy_child.target = player_target
