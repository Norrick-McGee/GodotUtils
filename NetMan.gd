extends Node
class_name NetMan

const DEFAULTPORT = 6767

var peer: MultiplayerPeer
func start_hosting():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULTPORT)
	peer.connect("peer_connected",print_peer)
	multiplayer.multiplayer_peer = peer
	
func print_peer(id):
	print("peer connected:", id)
func start_client(ip: String):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULTPORT)
	multiplayer.multiplayer_peer = peer
