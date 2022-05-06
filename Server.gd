extends Node


# Instance variables
var port: int = 42069
var allow_remote_players: bool = true
var peer: NetworkedMultiplayerENet

onready var player_manager  = $PlayerManager
onready var enemy_manager  = $EnemyManager


func _init() -> void:
	# Thank you https://github.com/LudiDorici/gd-custom-multiplayer
	# First, we assign a new MultiplayerAPI to our this node
	custom_multiplayer = MultiplayerAPI.new()
	# Then we need to specify that this will be the root node for this custom
	# MultiplayerAPI, so that all path references will be relative to this one
	# and only its children will be affected by RPCs/RSETs
	custom_multiplayer.set_root_node(self)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set random seed
	randomize()
	
	# Pass references
	self.enemy_manager.player_manager = self.player_manager
	
	# Actually start the server
	self.startServer()


# Called every frame
func _process(_delta: float) -> void:
	if not self.custom_multiplayer:
		return
	if not self.custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll();


func _physics_process(_delta: float) -> void:
	self.server_update()


########################################
#			Signals/Callbacks
########################################

func _on_peer_connected(peer_id: int) -> void:
	print("Peer with id=%s connected." % peer_id)
	

func _on_peer_disconnected(peer_id: int) -> void:
	self.player_manager.remove_player(peer_id)
	print("Peer with id=%s disconnected." % peer_id)


##########################################
#			Internal Functions
##########################################

func startServer() -> void:
	self.peer = NetworkedMultiplayerENet.new()
	if self.allow_remote_players:
		self.peer.set_bind_ip("*")
	else:
		self.peer.set_bind_ip("127.0.0.1")
	self.peer.create_server(port)
	self.multiplayer.set_network_peer(self.peer)
	print("Server has started...")
	
	var error: int = 0
	error += self.peer.connect("peer_connected", self, "_on_peer_connected")
	error += self.peer.connect("peer_disconnected", self, "_on_peer_disconnected")
	if error != OK:
		print("Error in server multiplayer signal connect.")
	
	# Quit if something failed
	if not self.peer:
		self.get_tree().quit()
	if self.peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		self.get_tree().quit()


func server_update() -> void:
	# Construct current state of the world
	var world: Dictionary = {}
	world["players"] = self.player_manager.serialize_players()
	world["enemies"] = self.enemy_manager.serialize_enemies()
	# Add the server's timestamp to the payload
	world["time"] = OS.get_system_time_msecs()
	# Send all players all information about the world
	rpc_unreliable_id(0, "client_receive_world_state", world)


##################################################
#			Outgoing Network Functions
##################################################


##################################################
#			Incoming Network Functions
##################################################

remote func server_receive_player_pos(state: Dictionary) -> void:
	# Get who sent this update
	var client_id: int = self.multiplayer.get_rpc_sender_id()
	# Pass it to the player manager
	self.player_manager.update_player_with_state(client_id, state)


remote func server_receive_enemy_hit(enemy_name: String) -> void:
	self.enemy_manager.hit_enemy(enemy_name)


remote func server_latency_ping(client_time: int) -> void:
	var client_id: int = self.multiplayer.get_rpc_sender_id()
	var server_time: int = OS.get_system_time_msecs()
	rpc_id(client_id, "client_latency_pong", client_time, server_time)


remote func request_data():
	print("Got rpc from client")
	var client_id: int = self.multiplayer.get_rpc_sender_id()
	rpc_id(client_id, "response_data", "Hello World")
