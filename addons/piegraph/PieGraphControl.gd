@tool
class_name pi_graph extends Control

@export var visualized_data: Array[float]:
	set(v):
		visualized_data = v
		queue_redraw()
@export var colors:Array[Color]:
	set(v):
		colors = v
		queue_redraw()

@export var default_color = Color.RED

func draw_circle_arc_poly(center:Vector2, radius:float, angle_from, angle_to, color):
	var nb_points = max(int((angle_to - angle_from) / 8.0),3)
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func calculate_total_weights(accum,current):
	return accum + max(current,0.0)
	
func remap_weights(element,total):
	var remapped = remap(max(element,0),0,total,0,360)
	return remapped


func _draw() -> void:
	var constrained_dimension_size_half = size[size.min_axis_index()]/2.0
	var center = size/2.0
	
	var total = visualized_data.reduce(calculate_total_weights,0)
	var arclength_values = visualized_data.map(remap_weights.bind(total))
	
	var arc_cursor:float = 0
	for i in arclength_values.size():
		var arc_length = arclength_values[i]
		var color = default_color
		if i < colors.size():
			color = colors[i]
		draw_circle_arc_poly(center,constrained_dimension_size_half,arc_cursor,arc_length + arc_cursor,color)
		arc_cursor += arc_length


func _ready() -> void:
	resized.connect(queue_redraw)
