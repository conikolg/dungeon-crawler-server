extends Node


# Instance variables
var player_scene: PackedScene = preload("res://actors/Player.tscn")


func update_player_with_state(player_id: int, state: Dictionary) -> void:
	# Try to pass this off to a particular player object
	for child in self.get_children():
		if child.name == str(player_id):
			child.update_with_state(state)
			return
	
	# Must be a new player
	var new_player: Player = self.player_scene.instance()
	new_player.name = str(player_id)
	new_player.update_with_state(state)
	self.add_child(new_player)


func serialize_players() -> Dictionary:
	var player_states: Dictionary = {}
	for child in self.get_children():
		player_states[child.name] = child.serialize()
	return player_states
