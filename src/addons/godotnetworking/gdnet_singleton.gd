extends Node

var peer: MultiplayerPeer

var return_callbacks: Dictionary[int, Callable] = {}
var registered_callbacks: Dictionary[int, Callable] = {}

var serializable_types: Dictionary[String, Serializable]

func get_serializable_by_name(_name: String) -> Serializable:
	assert(serializable_types.has(_name))
	return serializable_types[_name].duplicate_deep()

func start_multiplayer(_peer: MultiplayerPeer) -> void:
	peer = _peer
	multiplayer.multiplayer_peer = peer

func register_callback(callback: Callable) -> int:
	var id: int = randi()
	registered_callbacks[id] = callback
	return id

@rpc
func _internal_call_function(callback_id: int, args: Array, return_callback_id: int, sender: int) -> void:
	assert(registered_callbacks.has(callback_id), "The client requested to call an unregistered function.")
	var callback: Callable = registered_callbacks[callback_id]
	var ret: Variant = callback.callv(args)
	var is_serializable: bool = false
	if ret is Serializable:
		is_serializable = true
		ret = ret.to_primitive()
	assert(!ret is Object, "Return value of a remote function call must not be an object.")
	_internal_return_from_function.rpc_id(sender, return_callback_id, ret, is_serializable)

@rpc
func _internal_return_from_function(return_callback_id: int, ret: Variant, is_serializable: bool) -> void:
	assert(return_callbacks.has(return_callback_id), "The client requested to call an unregistered return function.")
	var callback: Callable = return_callbacks[return_callback_id]
	if is_serializable:
		ret = Serializable.from_primitive(ret)
	callback.call(ret)
	
