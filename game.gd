extends TileMapLayer

var snake_position : Vector2i = Vector2i(14,25)
var snake_tail_past_position : Vector2i
var snake_tail_position : Vector2i = snake_position
var snake_length : int
var snake_atlas = Vector2i(0,0)

var snake_direction : Vector2i = Vector2i(0, -1)

var food_position : Vector2i

var current_tick = 0
var tick_speed = 50

var junction_points = []

func _ready() -> void:
	set_snake_position()
	
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
		junction_points.append(snake_position)

func set_snake_position():
	if check_if_food_tile():
		snake_tail_position -= snake_direction
		snake_tail_past_position = snake_tail_position
		snake_length += 1
	erase_cell(snake_tail_past_position)
	set_cell(snake_position, 0, snake_atlas)


func game_tick():
	
	snake_tail_past_position = snake_tail_position 
	snake_position = snake_position + snake_direction
	if junction_points.size() == 0:
		snake_tail_position = snake_tail_position + snake_direction
	set_snake_position()

func check_if_food_tile() -> bool:
	var tile_data : TileData = get_cell_tile_data(snake_position)
	if tile_data:
		return tile_data.get_custom_data("is_food_tile")
	return false
