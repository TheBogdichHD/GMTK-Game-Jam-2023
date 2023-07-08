class_name Snake extends Area2D

@onready var path = $"../Path"

signal pressedSpace

signal killApple

func _input(event):
	if event.is_action("ui_accept"):
		pressedSpace.emit()

func _ready():
	pass
	
func _on_world_path_finded(id_path: Array[Vector2i]):
	var count = 0
	while count != id_path.size():
		await pressedSpace
		path.erase_cell(0, id_path[count])
		position = Vector2i(id_path[count].x*16+8, id_path[count].y*16+8)
		count+=1
	killApple.emit()
