extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene

var player : int
var moves : int
var winner : int
var temp_marker
var player_panel_pos : Vector2i
var grid_data : Array
var grid_pos : Vector2i
var board_size : int
var cell_size : int
var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int

var new_grid_data : Array
var rand_col : int
var rand_row : int
var size : int

var now_4 : int
var now_5 : int
var PB_wins: int
var Jam_wins: int

# Called when the node enters the scene tree for the first time.
func _ready():
	#AudioPlayer.play_music_level()
	board_size = $Board.texture.get_width()
	size = 3
	# divide board size by 3 to get the size of individual cell
	cell_size = board_size / size
	#get coordinates of small panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	now_4 = randf_range(2,8)
	now_5 = randf_range(12, 16-1)
	new_game()

func resize():
	size = size + 1
	cell_size = board_size / size
	rand_col = randf_range(0,size-1)
	rand_row = randf_range(0,size-1)
	for i in range(0,size-1):
		grid_data[i].insert(rand_col, 0)
	var array = []
	array.resize(size)
	array.fill(0)
	grid_data.insert(rand_row, array)
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	#create a marker to show starting player's turn
	if size == 4:
		create_marker(player, player_panel_pos + Vector2i(cell_size / 1.35, cell_size / 1.35), true)
		$Board.texture = load("res://assets/4x4.png")
	if size == 5:
		create_marker(player, player_panel_pos + Vector2i(cell_size / 1, cell_size / 1), true)
		$Board.texture = load("res://assets/5x5.png")
	get_tree().paused = false
	for i in range(0,size):
		for j in range(0,size):
			grid_pos = Vector2i(j,i)
			if grid_data[i][j] == 1:
				create_marker(1, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
			if grid_data[i][j] == -1:
				create_marker(-1, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if (moves == now_4) or (moves == now_5):
		resize()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#check if mouse is on the game board
			if event.position.x < board_size:
				#convert mouse position into grid location
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					#place that player's marker
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					
					# NOT WORKING
					if moves == 25:
						get_tree().paused = true
						if check_win() != 0:
							$GameOverMenu.show()
							if winner == 1:
								$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins!"
							elif winner == -1:
								$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins!"
						else:
							$GameOverMenu.show()
							$GameOverMenu.get_node("ResultLabel").text = "It's a Tie!"
					'''
					
					#WORKING
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins!"
						elif winner == -1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins!"
					#check if the board has been filled
					elif moves == size*size:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "It's a Tie!"
					'''
					
					player *= -1
					#update the panel marker
					temp_marker.queue_free()
					#create a marker to show starting player's turn
					#create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
					if size == 3:
						create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
					if size == 4:
						create_marker(player, player_panel_pos + Vector2i(cell_size / 1.35, cell_size / 1.35), true)
					if size == 5:
						create_marker(player, player_panel_pos + Vector2i(cell_size / 1.2, cell_size / 1.2), true)
					
func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
		]
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	#clear existing markers
	#Replace here with bread images
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	#create a marker to show starting player's turn
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(player, position, temp=false):
	#create a marker node and add it as a child
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		if size == 4:
			circle.scale.x = 0.13
			circle.scale.y = 0.13
		if size == 5:
			circle.scale.x = 0.105
			circle.scale.y = 0.105
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		if size == 4:
			cross.scale.x = 0.17
			cross.scale.y = 0.17
		if size == 5:
			cross.scale.x = 0.13
			cross.scale.y = 0.13
		add_child(cross)
		if temp: temp_marker = cross

func check_win():
	#add up the markers in each ros, column and diagonal
	'''
	for i in range(1,3):
			row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
			col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
			diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
			diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]

			#check if either player has all of the markers in one line
			if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
				winner = 1
			elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
				winner = -1
	'''
	for i in range(1,3):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[2][0] + grid_data[1][1] + grid_data[0][2]
		#check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			PB_wins += 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			PB_wins += -1
	for i in range(1,3):
		row_sum = grid_data[i][1] + grid_data[i][2] + grid_data[i][3]
		col_sum = grid_data[1][i] + grid_data[2][i] + grid_data[3][i]
		diagonal1_sum = grid_data[2][1] + grid_data[1][2] + grid_data[0][3]
		diagonal2_sum = grid_data[0][1] + grid_data[1][2] + grid_data[2][3]
		#check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			PB_wins += 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			Jam_wins += -1
		#check vertical
		if (grid_data[0][1] + grid_data[1][1] + grid_data[2][1] == 3):
			PB_wins -= 1
		elif (grid_data[0][1] + grid_data[1][1] + grid_data[2][1] == -3):
			Jam_wins -= 1
		if (grid_data[0][2] + grid_data[1][2] + grid_data[2][2] == 3):
			PB_wins -= 1
		elif (grid_data[0][2] + grid_data[1][2] + grid_data[2][2] == -3):
			Jam_wins -= 1
	for i in range(1,3):
		row_sum = grid_data[i][2] + grid_data[i][3] + grid_data[i][4]
		col_sum = grid_data[2][i] + grid_data[3][i] + grid_data[4][i]
		diagonal1_sum = grid_data[0][2] + grid_data[1][3] + grid_data[2][4]
		diagonal2_sum = grid_data[2][2] + grid_data[1][3] + grid_data[4][4]
		#check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			PB_wins += 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			PB_wins += -1
		#check vertical
		if (grid_data[0][2] + grid_data[1][2] + grid_data[2][2] == 3):
			PB_wins -= 1
		elif (grid_data[0][2] + grid_data[1][2] + grid_data[2][2] == -3):
			Jam_wins -= 1
		if (grid_data[0][3] + grid_data[1][3] + grid_data[2][3] == 3):
			PB_wins -= 1
		elif (grid_data[0][3] + grid_data[1][3] + grid_data[2][3] == -3):
			Jam_wins -= 1
	if PB_wins >= Jam_wins:
		winner = -1
	else: 
		winner = 1
	return winner


func _on_game_over_menu_restart():
	cell_size = board_size / 3
	size = 3
	$Board.texture = load("res://assets/3x3.png")
	new_game()
