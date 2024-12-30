extends TileMapLayer

var snake_position : Vector2i = Vector2i(14,25)
var snake_tail_past_position : Vector2i
var snake_tail_position : Vector2i = snake_position
var snake_length : int = 1
var score : int = 0
var snake_atlas = Vector2i(0,0)

var snake_direction : Vector2i = Vector2i(0, -1)

var food_position : Vector2i

var current_tick = 0
var tick_speed = 5

var junction_points = []
#var junction : 
#{index : [pos, dir]}

var pattern_ancor_ones = Vector2i(15, 39)
var pattern_ancor_tens = Vector2i(8, 39)

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
	check_if_snake_on_border()
	set_snake_tail_pos()
	set_snake_position()

func check_if_food_tile() -> bool:
	var tile_data : TileData = get_cell_tile_data(snake_position)
	if tile_data:
		return tile_data.get_custom_data("is_food_tile")
	return false

func on_eat_food():
	snake_length += 1
	score +=1
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
	var ones_index = null
	var tens_index = null
	if score > 9:
		tens_index = return_tens()
		var ten_pattern : TileMapPattern = tile_set.get_pattern(tens_index)
		set_pattern(pattern_ancor_tens, ten_pattern)
		ones_index = score % 10
		if ones_index == 0:
			ones_index = 9
		else:
			ones_index -= 1
		var one_pattern : TileMapPattern = tile_set.get_pattern(ones_index)
		set_pattern(pattern_ancor_ones, one_pattern)
	else:
		var pattern : TileMapPattern = tile_set.get_pattern(snake_length -2)
		set_pattern(pattern_ancor_ones, pattern)

func check_if_snake_eating_self() -> bool:
	var tile_data : TileData = get_cell_tile_data(snake_position)
	if tile_data:
		var is_snake_tile = tile_data.get_custom_data("is_snake_tile")
		if is_snake_tile:
			return true
	return false
	
func reset_game():
	get_tree().reload_current_scene()

func check_if_snake_on_border():
	if snake_position.x == 0: 
		reset_game()
	if snake_position.x == 39:
		reset_game()
	if snake_position.y == 0: 
		reset_game()
	if snake_position.y == 39:
		reset_game()
	
func return_tens():
	if score > 9 and score < 20:
		return 0
	elif score > 19 and score < 30:
		return 1
	elif score > 29 and score < 40:
		return 2
	elif score > 39 and score < 50:
		return 3
	elif score > 49 and score < 60:
		return 4
	elif score > 59 and score < 70:
		return 5
	elif score > 69 and score < 80:
		return 6
	elif score > 79 and score < 90:
		return 7
	elif score > 89 and score < 100:
		return 8
