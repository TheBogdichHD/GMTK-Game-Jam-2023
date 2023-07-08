class_name Snake extends Area2D

@onready var timer = $Timer
@onready var path = $Path

func _ready():
	pass
	
func _on_world_path_finded(id_path: Array[Vector2i]):
	var count = 0
	while count != id_path.size():
		
		await get_tree().create_timer(0.5).timeout
		path.set_cell(0, id_path[count], 0, Vector2i(1, 0))
		position = Vector2i(id_path[count].x*16+8, id_path[count].y*16+8)
		count+=1
		