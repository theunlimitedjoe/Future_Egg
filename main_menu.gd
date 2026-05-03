extends Node

var new_scene = preload("res://game.tscn") # preloads game

@onready var Play = $MarginContainer/CenterContainer/MainMenuFrame/Main_Menu/Play
@onready var More = $MarginContainer/CenterContainer/MainMenuFrame/Main_Menu/More
@onready var Options = $MarginContainer/CenterContainer/MainMenuFrame/Main_Menu/Options
@onready var Exit = $MarginContainer/CenterContainer/MainMenuFrame/Main_Menu/Exit
@onready var bg = $Background

var colors = [
	Color("#EDC5FC"),
	Color("#EFFCC5"),
	Color("#C5FCD2"),
	Color("#D2C5FC"),
	Color("#EDC5FC"),
	Color("#FCC5EF"),
	Color("#EFEFEF"),
	Color("#FCD2C5"),
	Color("#C5D4FC"),
	Color("#C5EFFC"),
	Color("#C5FCED")
]

func _ready() -> void:
	randomize()
	bg.color = colors[randi() % colors.size()]
	loop_colors()
	
	$MarginContainer/CenterContainer/MainMenuFrame/Main_Menu/Egg_Controller/Egg_Main.play("Egg_Loop")
	
	$MarginContainer.visible = true # Makes Main menu visible
	$Categorical.visible = false # and other menus invisible

func _process(delta: float) -> void:
	pass
	
#CHANGE BACKGROUND COLOR
func loop_colors():
	var next_color = colors[randi() % colors.size()]

	while next_color == bg.color:
		next_color = colors[randi() % colors.size()]

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(bg, "color", next_color, randf_range(25.0, 26.0))

	tween.finished.connect(loop_colors)

#PLAY BUTTON
func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(new_scene) # starts game
	
func _on_play_button_down() -> void:
	create_tween().tween_method(_set_play_size, 64, 60, 0.08)

func _on_play_button_up() -> void:
	create_tween().tween_method(_set_play_size, 60, 64, 0.08)

func _set_play_size(v):
	Play.add_theme_font_size_override("font_size", int(v))
	
#MORE BUTTON
func _on_more_pressed() -> void:
	$MarginContainer.visible = false # makes Main menu invisible
	$Categorical.visible = true # makes Categorical menu visible
	
func _on_more_button_down() -> void:
	create_tween().tween_method(_set_more_size, 64, 60, 0.08)

func _on_more_button_up() -> void:
	create_tween().tween_method(_set_more_size, 60, 64, 0.08)

func _set_more_size(v):
	More.add_theme_font_size_override("font_size", int(v))

#OPTIONS BUTTON
func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_options_button_down() -> void:
	create_tween().tween_method(_set_options_size, 64, 60, 0.08)

func _on_options_button_up() -> void:
	create_tween().tween_method(_set_options_size, 60, 64, 0.08)

func _set_options_size(v):
	Options.add_theme_font_size_override("font_size", int(v))

#EXIT BUTTON
func _on_exit_pressed() -> void:
	get_tree().quit() # quits game

func _on_exit_button_down() -> void:
	create_tween().tween_method(_set_exit_size, 64, 60, 0.08)

func _on_exit_button_up() -> void:
	create_tween().tween_method(_set_exit_size, 60, 64, 0.08)

func _set_exit_size(v):
	Exit.add_theme_font_size_override("font_size", int(v))

#==========BUY SCREEN================================================

#BUY BUTTON
func _on_buy_pressed() -> void:
	get_tree().change_scene_to_packed(new_scene) # starts game
	
#BACK BUTTON
func _on_back_pressed() -> void:
	$Categorical.visible = false # makes Categorical menu ivisible
	$MarginContainer.visible = true # makes Main menu visible
