extends Node2D

var current_score = 0;

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func increase_score(amount):
	current_score += amount;
	print(current_score);

func _on_grid_score_changed(amount):
	increase_score(amount);
