extends Control

var MENUCOUNT = 3

onready var MenuOptions = $MarginContainer/VBoxContainer/Menu

var selected = 0

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		move_selector(1)
	elif Input.is_action_just_pressed("ui_up"):
		move_selector(-1)
	
	# modify appearance of menu
	for i in range(MENUCOUNT):
		if i == selected:
			MenuOptions.get_child(i).size_flags_stretch_ratio = 2
			MenuOptions.get_child(i).margin_left = 32
			#MenuOptions.get_child(i).font
		else:
			MenuOptions.get_child(i).size_flags_stretch_ratio = 1
			MenuOptions.get_child(i).margin_left = 0
	
	if Input.get_action_strength("ui_accept"):
			select_item(selected)

func move_selector(move):
	selected += move
	# wrap selected between 0 and menu count
	if selected >= MENUCOUNT:
		selected = 0
	elif selected < 0:
		selected = MENUCOUNT - 1

func select_item(index):
	match index:
		0: # play
			get_tree().change_scene("res://scenes/Scene_1.tscn")
		1: # options
			print("options")
		2: # exit
			get_tree().quit()
