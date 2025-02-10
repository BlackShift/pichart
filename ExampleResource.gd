@tool
class_name ExampleResource extends Resource


#Emit changed is neccesary in order for graph elements to update
@export var name:String:
	set(v):
		name = v
		emit_changed()
@export var amount:float:
	set(v):
		amount = v
		emit_changed()
