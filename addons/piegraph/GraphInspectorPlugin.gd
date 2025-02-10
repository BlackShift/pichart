@tool
extends EditorInspectorPlugin

const GRAPH_DISPLAY = preload("res://addons/piegraph/GraphDisplay.tscn")

var graphs:Dictionary

func _init() -> void:
	pass

func _can_handle(object):
	return true

## This detects if we are editing an Array[ExampleResource]. Typing required.
func _parse_property(object, type, path, hint, hint_text, usage, wide):
	if type == TYPE_ARRAY:
		if object[path].get_typed_builtin() == TYPE_OBJECT:
			var script_obj = object[path].get_typed_script() as Script
			if !script_obj or script_obj.get_global_name() != "ExampleResource":
				return false
			print("Adding editor")
			var graph = GRAPH_DISPLAY.instantiate()
			graph.setup(object,path) #Enable a hook to catch changes
			add_custom_control(graph)
		return false
	else:
		return false
