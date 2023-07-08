extends Node2D

signal path_finded

@onready var game_map = $GameMap
@onready var path = $Path
@onready var start = $Snake
@onready var goal = $Goal

var astar_grid: AStarGrid2D
var start_cell: Vector2i
var end_cell: Vector2i

func _ready() -> void:
	_init_grid()
	astar_grid.default_compute_heuristic = 0
	astar_grid.default_estimate_heuristic = 0
	astar_grid.diagonal_mode = 1
	_update_grid_from_tilemap()
	find_path()

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var applescene = load("res://Nodes/apple.tscn")
		var apple = applescene.instantiate()
		apple.position = game_map.local_to_map(get_local_mouse_position())*16 + Vector2i(8, 8)
		add_child(apple)
		goal = apple 

func _on_layout_updated() -> void:
	_update_grid_from_tilemap()
	find_path()

func _on_marker_positions_updated() -> void:
	var new_start_cell = game_map.local_to_map(start.position)
	var new_end_cell = game_map.local_to_map(goal.position)
	
	if new_start_cell != start_cell or new_end_cell != end_cell:
		find_path()

# Create an AStarGrid2D instance from the size of the game map
# Note that fundamental changes like size and cell_size require
# calling update() on the grid before it is usable
func _init_grid() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.size = game_map.get_used_rect().size
	astar_grid.cell_size = game_map.tile_set.tile_size
	astar_grid.update()

# Look up each grid cell in our AStarGrid2D instance
# and set it to solid based on whether or not it is a wall in the game map
func _update_grid_from_tilemap() -> void:
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var id = Vector2i(i, j)
			# If game_map does not have a cell source id >= 0
			# then we're looking at an invalid location
			if game_map.get_cell_source_id(0, id) >= 0:
				var tile_type = game_map.get_cell_tile_data(0, id).get_custom_data('tile_type')
				astar_grid.set_point_solid(Vector2i(i, j), tile_type == 'wall')
			# If looking at a location outside of the game map,
			# default to marking the cell solid so the player can't navigate
			# outside of the game map.
			# Shouldn't be an issue in this demo since grid size comes from map size
			# but something to keep in mind.
			else:
				astar_grid.set_point_solid(Vector2i(i, j), true)
				

func find_path() -> void:
	path.clear()
	start_cell = game_map.local_to_map(start.position)
	end_cell = game_map.local_to_map(goal.position)
	
	if start_cell == end_cell or !astar_grid.is_in_boundsv(start_cell) or !astar_grid.is_in_boundsv(end_cell):
		return

	var id_path = astar_grid.get_id_path(start_cell, end_cell)
	for id in id_path:
		path.set_cell(0, id, 1, Vector2(0, 0))
	
	path_finded.emit(id_path)


func _on_snake_kill_apple():
	goal.queue_free()
