@tool
extends EditorPlugin
const GraphInspectorPlugin = preload("res://addons/piegraph/GraphInspectorPlugin.gd")

func _enter_tree() -> void:
	print("PieGraph Started!")
	add_inspector_plugin(GraphInspectorPlugin.new())
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
