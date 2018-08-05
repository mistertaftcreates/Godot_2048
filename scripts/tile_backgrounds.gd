extends Node2D

export (PackedScene) var tile_background;
var width = 4;
var height = 4;
var x_start = 96;
var y_start = 704;

func _ready():
	setup();

func setup():
	for i in width:
		for j in height:
			var bkg = tile_background.instance();
			add_child(bkg);
			bkg.position = Vector2(x_start + i * 128, y_start + j * -128);

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
