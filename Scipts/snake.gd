class_name Snake extends Area2D

@onready var timer = $Timer

func _ready():
	pass
	
func _on_world_path_finded(id_path: Array[Vector2i]):
	var count = 0
	while count != id_path.size():
		
		if timer.time_left > 0.0:
			position = Vector2i(id_path[count].x*16+8, id_path[count].y*16+8)
			count+=1
		timer.start()
		
