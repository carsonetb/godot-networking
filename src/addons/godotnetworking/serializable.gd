@abstract
class_name Serializable
extends Object

func base_data() -> Dictionary[String, Variant]:
	return {
		"name": get_unique_name()
	}

@abstract
func get_unique_name() -> String

@abstract
func to_primitive() -> Dictionary[String, Variant]

@abstract func generate(data: Dictionary[String, Variant])

static func from_primitive(primitive: Dictionary[String, Variant]) -> Serializable:
	var ret: Serializable = GDNetSingleton.get_serializable_by_name(primitive["name"])
	ret.generate(primitive)
	return ret
