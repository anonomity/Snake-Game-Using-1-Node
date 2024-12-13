extends TileMapLayer

var snake_position : Vector2i = Vector2i(14,25)
var snake_tail_past_position : Vector2i
var snake_tail_position : Vector2i = snake_position
var snake_length : int = 1
var snake_atlas = Vector2i(0,0)

var snake_direction : Vector2i = Vector2i(0, -1)

var food_position : Vector2i

var current_tick = 0
var tick_speed = 10

var junction_points = []
#var junction : 
#{index : [pos, dir]}

var pattern_ancor = Vector2i(15, 39)

func _ready() -> void:
	set_snake_position()
	set_food_position()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()
	if event.is_action_pressed("ui_left"):
		check_junction()
		snake_direction = Vector2i(-1, 0)
	if event.is_action_pressed("ui_right"):
		check_junction()
		snake_direction = Vector2i(1, 0)
	if event.is_action_pressed("ui_up"):
		check_junction()
		snake_direction = Vector2i(0, -1)
	if event.is_action_pressed("ui_down"):
		check_junction()
		snake_direction = Vector2i(0, 1)

func _process(delta: float) -> void:
	if current_tick == tick_speed:
		game_tick()
		current_tick = 0
	else:
		current_tick += 1

func check_junction():
	if snake_length > 1:
		junction_points.append([snake_position , snake_direction])

func set_snake_position():
	if check_if_food_tile():
		on_eat_food()
		set_food_position()
		set_score()
		
	erase_cell(snake_tail_past_position)
	set_cell(snake_position, 0, snake_atlas)

func game_tick():
	snake_tail_past_position = snake_tail_position 
	snake_position = snake_position + snake_direction
	if check_if_snake_eating_self():
		reset_game()
	set_snake_tail_pos()
	set_snake_position()

func check_if_food_tile() -> bool:
	var tile_data : TileData = get_cell_tile_data(snake_position)
	if tile_data:
		return tile_data.get_custom_data("is_food_tile")
	return false

func on_eat_food():
	snake_length += 1
	if junction_points.size() == 0:
		snake_tail_position -= snake_direction
	else:
		snake_tail_position -= junction_points[0][1]


func set_snake_tail_pos():
	if junction_points.size() == 0:
		snake_tail_position = snake_tail_position + snake_direction
	else:
		snake_tail_position = snake_tail_position +  junction_points[0][1]
		print(snake_tail_position)
		if snake_tail_position == junction_points[0][0]:
			junction_points.pop_front()

func set_food_position():
	var is_valid_pos = false
	var rand_pos
	while !is_valid_pos:
		rand_pos = random_pos()
		var tile_data : TileData = get_cell_tile_data(rand_pos)	
		if tile_data:
			var is_snake_tile = tile_data.get_custom_data("is_snake_tile")
			if !is_snake_tile:
				is_valid_pos = true
		else:
			is_valid_pos = true
	set_cell(rand_pos , 0, Vector2i(1,0))
	
func random_pos():
	var random_x = randi_range(1, 38)
	var random_y = randi_range(1, 38)
	return Vector2i(random_x, random_y)

func set_score():
	var pattern : TileMapPattern = tile_set.get_pattern(snake_length -2)
	set_pattern(pattern_ancor, pattern)

func check_if_snake_eating_self() -> bool:
	var tile_data : TileData = get_cell_tile_data(snake_position)
	if tile_data:
		var is_snake_tile = tile_data.get_custom_data("is_snake_tile")
		if is_snake_tile:
			return true
	return false
	
func reset_game():
	get_tree().reload_current_scene()
