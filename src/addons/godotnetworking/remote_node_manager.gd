class_name RemoteNodeManager
extends Node

var node_owner: bool = false

var _function_id_map: Dictionary[String, int]
var _name_function_map: Dictionary[String, Callable]

func _ready() -> void:
	var parent: Node = get_parent()
	for method_info: Dictionary in get_parent().get_method_list():
		var method_name: String = method_info.name
		var callable: Callable = Callable(parent, method_name)
		_name_function_map[method_name] = callable
	
	if node_owner:
		var i: int = 0
		for callable: Callable in _name_function_map.values():
			var func_name: String = _name_function_map.keys()[i]
			_function_id_map[func_name] = GDNetSingleton.register_callback(callable)
			_internal_register_id.rpc(func_name, _function_id_map[func_name])
			i += 1

func call_func(func_name: String, return_func: Callable = Callable()) -> void:
	pass

@rpc
func _internal_register_id(callable_name: String, id: int) -> void:
	_function_id_map[callable_name] = id
