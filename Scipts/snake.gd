class_name Snake extends Area2D

@onready var path = $"../Path"
@onready var game_map = $"../GameMap"
@onready var head_sprite = $Head/Head

signal pressedSpace

signal killApple

signal change_grid

var segments: Array

func _ready():
	segments.push_back(self)
	segments.push_back($"../Body")
	segments.push_back($"../Body1")
	segments.push_back($"../Body2")

func _input(event):
	if event.is_action("ui_accept"):
		pressedSpace.emit()

func _on_world_path_finded(id_path: Array[Vector2i]):
	var count = 0
	var prev_pos
	while count != id_path.size()-1:
		await pressedSpace
		await get_tree().create_timer(0.05).timeout
		
		
			
		path.erase_cell(0, id_path[count+1])
		prev_pos = position
		position = Vector2i(id_path[count+1].x*16+8, id_path[count+1].y*16+8)
		var x = (segments.back().position.x-8)/16
		var y = (segments.back().position.y-8)/16
		change_head(prev_pos, position)
		
		if count >= id_path.size()-2:
			change_grid.emit(id_path[count+1], Vector2i(x, y), true)
		else:
			change_grid.emit(id_path[count+1], Vector2i(x, y), false)
		
		for i in range(1, segments.size()):
			var t = segments[i].position
			segments[i].position = prev_pos 
			prev_pos = t
		count+=1
	killApple.emit()
	
	var bodyscene = load("res://Nodes/body.tscn")
	var body = bodyscene.instantiate()
	body.position = prev_pos
	add_sibling(body)
	segments.push_back(body)

func change_head(prev, next):
	var vec = Vector2i((prev.x - 8 - next.x - 8)/16, (prev.y - 8 - next.y - 8)/16)
	if vec == Vector2i(-2,-1):
		head_sprite.frame = 1
	elif vec == Vector2i(-1,-2):
		head_sprite.frame = 4
	elif vec == Vector2i(0,-1):
		head_sprite.frame = 2
	elif vec == Vector2i(-1,0):
		head_sprite.frame = 3

func _on_world_grid_update(astar_grid):
	for segment in segments:
		var i = (segment.position.x-8)/16
		var j = (segment.position.y-8)/16
		astar_grid.set_point_solid(Vector2i(i, j), true)
