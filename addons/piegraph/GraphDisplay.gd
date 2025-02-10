@tool
extends VBoxContainer

const KEY_ITEM = preload("res://addons/piegraph/key_item.tscn")
const GLOBAL_COLORS = preload("res://addons/piegraph/GLOBAL_COLORS.tres")

@onready var pi_graph_node: pi_graph = %pi_graph
@onready var graph_key: VBoxContainer = %graph_key

var random := RandomNumberGenerator.new()
@onready var start_state = random.state

var monitored_object
var monitored_property

func _ready() -> void:
	if !monitored_object or !monitored_property:
		return
	var resource_array = monitored_object[monitored_property]
	update(resource_array)

func setup(object,property) -> void:
	monitored_object = object
	monitored_property = property
	var inspector := EditorInterface.get_inspector()
	inspector.property_edited.connect(check_for_changes.bind(inspector))


func check_for_changes(changed_property,inspector:EditorInspector) -> void:
	print(changed_property, "?=", monitored_property)
	var changed_object = inspector.get_edited_object()
	if monitored_object != changed_object:
		return
	if monitored_property != changed_property:
		return
	var resource_array = monitored_object[monitored_property]
	update(resource_array)

func get_values(el:ExampleResource):
	if el:
		return el.amount
	return 0.0

func get_colors(el:ExampleResource):
	if el:
		if GLOBAL_COLORS.color_map.has(el.name):
			return GLOBAL_COLORS.color_map[el.name]
		random.seed = el.name.hash()
		return Color.from_hsv(random.randf(),random.randf(),1.0,1.0)
		
	return Color.BLACK

func sort_by_probability(el_a:int,el_b:int,source:Array[ExampleResource]):
	var el_resource_a := source[el_a]
	var el_resource_b := source[el_b]
	
	#because source may contain null resources this array gets messy
	if el_resource_a and el_resource_b:
		if el_resource_a.amount > el_resource_b.amount:
			return true
		else:
			return false
	elif el_resource_a and !el_resource_b:
		return true
	elif !el_resource_a and el_resource_b:
		return false
	else:
		if el_a > el_b:
			return true
		else:
			return false
	pass #Should never reach


func update(source:Array[ExampleResource]):
	#reconect signals
	for s:ExampleResource in source:
		if s and s.changed.is_connected(update):
			s.changed.disconnect(update) #We have to reconect to update the bound resource
		if s and !s.changed.is_connected(update):
			s.changed.connect(update.bind(source))
	
	var probability_values := Array(source.map(get_values),TYPE_FLOAT,"",null)
	var colors = Array(source.map(get_colors),TYPE_COLOR,"",null)
	
	for c in graph_key.get_children():
		c.queue_free()
	
	
	var sorted_array = range(source.size())
	sorted_array.sort_custom(sort_by_probability.bind(source))
	
	
	pi_graph_node.visualized_data = probability_values
	pi_graph_node.colors = colors
	
	
	for source_idx in sorted_array:
		var item_label = KEY_ITEM.instantiate()
		if source[source_idx]:
			item_label.get_node("Label").text = source[source_idx].name + " - " + String.num(source[source_idx].amount,2)
		else:
			item_label.get_node("Label").text = "[undefined]"
		item_label.get_node("ColorRect").color = colors[source_idx]
		graph_key.add_child(item_label)
