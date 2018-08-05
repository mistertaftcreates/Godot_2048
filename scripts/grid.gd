extends Node2D

# Signals
signal score_changed;

# Grid Variables
export (int) var x_start;
export (int) var y_start;
export (int) var offset;
export (int) var num_starting_pieces;
export (int) var width;
export (int) var height;

# Touch Variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var last_direction = 0;

# Piece Variables
var possible_pieces = [
preload("res://scenes/2_piece.tscn"),
preload("res://scenes/4_piece.tscn")
]
var all_pieces = [];

func _ready():
	randomize();
	all_pieces = make_2d_array();
	setup();

func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func setup():
	var current_pieces = 0;
	var starting_pieces = 8;
	while current_pieces < starting_pieces:
		var current_x = round(rand_range(0, 3.4));
		var current_y = round(rand_range(0, 3.4));
		if(all_pieces[current_x][current_y] == null):
			var piece_to_make = round(rand_range(0, 1.4));
			var piece = possible_pieces[0].instance();
			current_pieces += 1;
			add_child(piece);
			piece.position = grid_to_pixel(Vector2(current_x, current_y));
			all_pieces[current_x][current_y] = piece;

func grid_to_pixel(grid_position):
	var new_x = grid_position.x * offset + x_start;
	var new_y = grid_position.y * -offset + y_start;
	return (Vector2(new_x, new_y));

func pixel_to_grid(pixel_position):
	var new_x = round((pixel_position.x - x_start) / offset);
	var new_y = round((pixel_position.y - y_start) / -offset);
	return (Vector2(new_x, new_y));

func _process(delta):
	touch_input();

func touch_input():
	if(Input.is_action_just_pressed("ui_touch")):
		first_touch = (get_global_mouse_position());
	if(Input.is_action_just_released("ui_touch")):
		final_touch = (get_global_mouse_position());
		calculate_direction();
		swipe_angle();

func swipe_angle():
	var difference = final_touch - first_touch;
	var angle = rad2deg(atan2(difference.x, difference.y));
	print(angle);

func calculate_direction():
	last_direction = 0;
	var difference = final_touch - first_touch;
	if abs(difference.x) > abs(difference.y):
		if difference.x >= 25:
			for i in range(3, -1, -1):
				for j in height: 
					if all_pieces[i][j] != null:
						move_right(i,j, Vector2(1, 0));
						last_direction = 1;
		elif difference.x <= -25:
			for i in range(1, 4, 1):
				for j in height:
					if all_pieces[i][j] != null:
						move_left(i,j);
						last_direction = 2;
	elif abs(difference.x) <= abs(difference.y):
		if difference.y <= -25:
			for i in width:
				for j in range(3, -1, -1):
					if all_pieces[i][j] != null:
						move_up(i,j);
						last_direction = 3;
		elif difference.y >= 25:
			for i in width:
				for j in range(1, 4, 1):
					if all_pieces[i][j] != null:
						move_down(i,j);
						last_direction = 4;
	if abs(difference.x) >= 25 || abs(difference.y) >= 25:
		fill_board();

func move_right(column, row, direction):
	# Store this piece
	var this_piece = all_pieces[column][row];
	# Store the value of the next column
	var next_x = column + 1;
	# Store the value of this piece:
	var value = all_pieces[column][row].value;
	# Iterate through the columns looking for the end of the board, or a
	# non-empty space.
	for i in range(next_x, width):
		# If it's the end of the board, and that spot is null:
		if i == width - 1 && all_pieces[i][row] == null:
			# Move the piece there:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(width - 1, row)));
			all_pieces[width - 1][row] = this_piece;
			break;
		# If this spot is full, then move to one before it:
		if all_pieces[i][row] != null && all_pieces[i][row].value != value:
			# Move to one before it:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(i - 1, row)));
			all_pieces[i - 1][row] = this_piece;
			break;
		if all_pieces[i][row] != null && all_pieces[i][row].value == value:
			all_pieces[column][row] = null;
			all_pieces[i][row].start_timer();
			this_piece.move(grid_to_pixel(Vector2(i, row)));
			this_piece.start_timer();
			var new_piece = this_piece.next_piece.instance();
			add_child(new_piece);
			print(new_piece);
			all_pieces[i][row] = new_piece;
			new_piece.position = grid_to_pixel(Vector2(i, row));
			emit_signal("score_changed", new_piece.value);
			break;

func move_left(column, row):
	# Store this piece
	var this_piece = all_pieces[column][row];
	# Store the value of the next column
	var next_x = column - 1;
	# Store the value of this piece:
	var value = all_pieces[column][row].value;
	# Iterate through the columns looking for the end of the board, or a
	# non-empty space.
	for i in range(next_x, -1, -1):
		# If it's the end of the board, and that spot is null:
		if i == 0 && all_pieces[i][row] == null:
			# Move the piece there:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(0, row)));
			all_pieces[0][row] = this_piece;
			break;
		# If this spot is full, then move to one before it:
		if all_pieces[i][row] != null && all_pieces[i][row].value != value:
			# Move to one before it:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(i + 1, row)));
			all_pieces[i + 1][row] = this_piece;
			break;
		if all_pieces[i][row] != null && all_pieces[i][row].value == value:
			all_pieces[column][row] = null;
			all_pieces[i][row].start_timer();
			this_piece.move(grid_to_pixel(Vector2(i, row)));
			this_piece.start_timer();
			var new_piece = this_piece.next_piece.instance();
			add_child(new_piece);
			print(new_piece);
			all_pieces[i][row] = new_piece;
			new_piece.position = grid_to_pixel(Vector2(i, row));
			emit_signal("score_changed", new_piece.value);
			break;

func move_up(column, row):
		# Store this piece
	var this_piece = all_pieces[column][row];
	# Store the value of the next column
	var next_y = row + 1;
	# Store the value of this piece:
	var value = all_pieces[column][row].value;
	# Iterate through the columns looking for the end of the board, or a
	# non-empty space.
	for i in range(next_y, width):
		# If it's the end of the board, and that spot is null:
		if i == width - 1 && all_pieces[column][i] == null:
			# Move the piece there:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(column, width - 1)));
			all_pieces[column][width - 1] = this_piece;
			break;
		# If this spot is full, then move to one before it:
		if all_pieces[column][i] != null && all_pieces[column][i].value != value:
			# Move to one before it:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(column, i - 1)));
			all_pieces[column][i - 1] = this_piece;
			break;
		if all_pieces[column][i] != null && all_pieces[column][i].value == value:
			all_pieces[column][row] = null;
			all_pieces[column][i].start_timer();
			this_piece.move(grid_to_pixel(Vector2(column, i)));
			this_piece.start_timer();
			var new_piece = this_piece.next_piece.instance();
			add_child(new_piece);
			print(new_piece);
			all_pieces[column][i] = new_piece;
			new_piece.position = grid_to_pixel(Vector2(column, i));
			emit_signal("score_changed", new_piece.value);
			break;
	pass;

func move_down(column, row):
	# Store this piece
	var this_piece = all_pieces[column][row];
	# Store the value of the next column
	var next_y = row - 1;
	# Store the value of this piece:
	var value = all_pieces[column][row].value;
	# Iterate through the columns looking for the end of the board, or a
	# non-empty space.
	for i in range(next_y, -1, -1):
		# If it's the end of the board, and that spot is null:
		if i == 0 && all_pieces[column][i] == null:
			# Move the piece there:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(column, 0)));
			all_pieces[column][0] = this_piece;
			break;
		# If this spot is full, then move to one before it:
		if all_pieces[column][i] != null && all_pieces[column][i].value != value:
			# Move to one before it:
			all_pieces[column][row] = null;
			this_piece.move(grid_to_pixel(Vector2(column, i + 1)));
			all_pieces[column][i + 1] = this_piece;
			break;
		if all_pieces[column][i] != null && all_pieces[column][i].value == value:
			all_pieces[column][row] = null;
			all_pieces[column][i].start_timer();
			this_piece.move(grid_to_pixel(Vector2(column, i)));
			this_piece.start_timer();
			var new_piece = this_piece.next_piece.instance();
			add_child(new_piece);
			all_pieces[column][i] = new_piece;
			new_piece.position = grid_to_pixel(Vector2(column, i));
			emit_signal("score_changed", new_piece.value);
			break;

func fill_board():
	if blank_space_on_board():
		generate_new_piece();
	else:
		if is_possible_match():
			return;
		else:
			print("Game Over");

func generate_new_piece():
	# Make a new piece in a blank space
	if(last_direction == 1):
		var piece_made = false;
		while !piece_made:
			var row = round(rand_range(-.5, 3.4));
			if(all_pieces[0][row] == null):
				var piece = possible_pieces[0].instance();
				add_child(piece);
				piece.position = grid_to_pixel(Vector2(0, row));
				piece_made = true;
				all_pieces[0][row] = piece;
	elif(last_direction == 2):
		var piece_made = false;
		while !piece_made:
			var row = round(rand_range(-.5, 3.4));
			if all_pieces[3][row] == null:
				var piece = possible_pieces[0].instance();
				add_child(piece);
				piece.position = grid_to_pixel(Vector2(3, row));
				piece_made = true;
				all_pieces[3][row] = piece;
	elif(last_direction == 3):
		var piece_made = false;
		while !piece_made:
			var column = round(rand_range(-.5, 3.4));
			if all_pieces[column][0] == null:
				var piece = possible_pieces[0].instance();
				add_child(piece);
				piece.position = grid_to_pixel(Vector2(column, 0));
				piece_made = true;
				all_pieces[column][0] = piece;
	elif(last_direction == 4):
		var piece_made = false;
		while !piece_made:
			var column = round(rand_range(-.5, 3.4));
			if all_pieces[column][3] == null:
				var piece = possible_pieces[0].instance();
				add_child(piece);
				piece.position = grid_to_pixel(Vector2(column, 3));
				piece_made = true;
				all_pieces[column][3] = piece;

func is_possible_match():
	# Check the four directions to see if the value matches
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var value = all_pieces[i][j].value;
				if j > 0:
					if all_pieces[i][j - 1].value == value:
						return true;
				if j < width - 1:
					if all_pieces[i][j + 1].value == value:
						return true;
				if i > 0:
					if all_pieces[i -1][j].value == value:
						return true;
				if i < width - 1:
					if all_pieces[i + 1][j].value == value:
						return true;
	return false;

func blank_space_on_board():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				return true;
	return false

func possible_match_on_board():
	# If there are any blank spaces, return null
	if blank_space_on_board():
		return true;
	# Otherwise, loop through all of the pieces, and check the four directions
	# If there is a match there, then return true
	if is_possible_match():
		return true;
	return false;

