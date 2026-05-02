extends Node

@onready var QuestionLabel = $MarginContainer/VBoxContainer/Question
@onready var AnswerInput1 = $MarginContainer/VBoxContainer/Answer_One
@onready var AnswerInput2 = $MarginContainer/VBoxContainer/Answer_Two
@onready var AnswerInput3 = $MarginContainer/VBoxContainer/Answer_Three
@onready var RevealPanel = $Reveal_Panel
@onready var ResultsLabel = $Reveal_Panel/MarginContainer/CenterContainer/Results
@onready var NextButton = $HBoxContainer/VBoxContainer/HBoxContainer/Next
@onready var QuestionAndAnswers = $MarginContainer
@onready var BackAndNext = $HBoxContainer
@onready var JustBack = $HBoxContainer/VBoxContainer/HBoxContainer/Back
@onready var Background = $Background
@onready var QuitButton = $HBoxContainer/VBoxContainer/HBoxContainer/Quit
@onready var BackButton = $HBoxContainer/VBoxContainer/HBoxContainer/Back
@onready var Perceiving1 = $HBoxContainer2/PERCEIVING_1
@onready var menu_scene = preload("res://main_menu.tscn") # preloads menu


var color_pool = [
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
	Color("#C5FCED"),
]
var is_waiting = false

var questions = [
	"Who do you want to be with?", #lover
	"What is the most beautiful place?", #place of marriage
	"What is the most romantic song?",#walk down the aisle to this song
	"Where would you want to live?",#place you live
	"How many doughnuts can you eat? How many can your lover eat?",#how many kids will you have? _______.
	"What is a sweet name for a pet?", #your lover calls you by your nickname _____
	"What hobby do you wish you had?",#favorite past time together
	"What do you want out of a romantic relationship?" #You both agreed that _____ was the most important thing.
]

var random_answer_pool = [
	["the Devil", "a very small robot", "a clone of myself"],
	["my neighbors backyard", "the highway", "an old attic"],
	["MMMBop", "Five Little Monkeys", "Halloween Theme"],
	["a dungeon in Europe", "a prison on the Moon", "in a tent on a roof."],
	["7 without buns", "enough", "no more than necessary"],
	["the One Who Watches", "the Unforgotten", "Captain Wuddles"],
	["safe cracking", "collecting varius dirt", "walking in strangers yards"],
	["money", "worshiping cats", "stopping the aging process"]
]

var current_question = 0

# Stores all answers per question
var answers = []

# Final results
var final_answers = []

# NEW: working answers for elimination animation
var working_answers = []

var revealed = []

func _ready():
	randomize_background()
	
	
	
	Perceiving1.visible = false
	RevealPanel.visible = false
	QuestionAndAnswers.visible = true
	BackAndNext.visible = true
	
	answers.resize(questions.size())
	revealed.resize(questions.size())
	revealed.fill(false)
	AnswerInput3.editable = false
	AnswerInput3.visible = false
	show_question()
	
	NextButton.disabled = true
	AnswerInput1.text_changed.connect(_on_answer_changed)
	AnswerInput2.text_changed.connect(_on_answer_changed)
	


func randomize_background():
	var chosen = color_pool[randi() % color_pool.size()]
	Background.color = chosen
	
	var text_color = get_contrast_color(chosen)
	ResultsLabel.add_theme_color_override("font_color", text_color)
	QuestionLabel.add_theme_color_override("font_color", text_color)

func get_contrast_color(bg: Color) -> Color:
	var luminance = (0.299 * bg.r) + (0.587 * bg.g) + (0.114 * bg.b)

	if luminance > 0.7:
		return bg.darkened(0.75)

	elif luminance > 0.45:
		return bg.darkened(0.6)

	else:
		return bg.lightened(0.8)

func _on_answer_changed(_new_text: String = "") -> void:
	NextButton.disabled = AnswerInput1.text.strip_edges() == "" or AnswerInput2.text.strip_edges() == ""

func show_question():
	QuestionLabel.text = questions[current_question]
	AnswerInput3.visible = revealed[current_question]
	QuitButton.visible = true
	QuitButton.disabled = false
	BackButton.modulate = Color(1, 1, 1, 0) if current_question == 0 else Color(1, 1, 1, 1)
	if answers[current_question] != null:
		AnswerInput1.text = answers[current_question][0]
		AnswerInput2.text = answers[current_question][1]
		AnswerInput3.text = answers[current_question][2]
	else:
		AnswerInput1.text = ""
		AnswerInput2.text = ""
		AnswerInput3.text = ""
		
	_on_answer_changed()


func _on_next_pressed() -> void:
	if is_waiting:
		return
	
	var a1 = AnswerInput1.text
	var a2 = AnswerInput2.text
	
	if a1 == "" or a2 == "":
		return
	
	is_waiting = true
	NextButton.disabled = true
	BackButton.disabled = true
	QuitButton.disabled = true
	AnswerInput1.editable = false
	AnswerInput2.editable = false
	AnswerInput1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AnswerInput2.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var was_already_revealed = revealed[current_question]

	AnswerInput3.visible = true
	revealed[current_question] = true

	var random_choice: String
	
	if answers[current_question] != null:
		random_choice = answers[current_question][2]
	else:
		var pool = random_answer_pool[current_question]
		random_choice = pool[randi() % pool.size()]
		answers[current_question] = [a1, a2, random_choice]
	
	AnswerInput3.text = random_choice

	if not was_already_revealed:
		await get_tree().create_timer(3.0).timeout
	
	AnswerInput1.editable = true
	AnswerInput2.editable = true
	AnswerInput1.mouse_filter = Control.MOUSE_FILTER_STOP
	AnswerInput2.mouse_filter = Control.MOUSE_FILTER_STOP
	BackButton.disabled = false

	current_question += 1
	is_waiting = false
	NextButton.disabled = false
	
	if current_question < questions.size():
		show_question()
	else:
		start_reveal_phase()


func _on_back_pressed() -> void:
	if current_question == 0:
		return
	
	current_question -= 1
	show_question()


func play_perceiving_intro():
	Perceiving1.visible = true

	# Play animation "1" twice
	for i in range(2):
		Perceiving1.play("1")
		await Perceiving1.animation_finished

	# Play animation "2" once
	Perceiving1.play("2")
	await Perceiving1.animation_finished

	# Play animation "3" once
	Perceiving1.play("3")
	await Perceiving1.animation_finished
	
	# Play animation "4" once
	Perceiving1.play("4")
	await Perceiving1.animation_finished
	
	# Play animation "5" on loop
	Perceiving1.play("5")

# =========================
# 🎬 ELIMINATION PHASE
# =========================

func start_reveal_phase():
	# Hide everything first
	QuestionAndAnswers.visible = false
	BackAndNext.visible = false
	RevealPanel.visible = false
	
	AnswerInput1.visible = false
	AnswerInput2.visible = false
	AnswerInput3.visible = false
	QuestionLabel.visible = false
	
	await play_perceiving_intro()
	
	# Now animation "3" is looping while elimination begins
	QuestionAndAnswers.visible = true
	QuestionLabel.visible = true
	
	AnswerInput1.visible = true
	AnswerInput2.visible = true
	AnswerInput3.visible = true
	
	working_answers.clear()
	
	BackAndNext.visible = false
	AnswerInput1.editable = false
	AnswerInput2.editable = false
	AnswerInput3.editable = false
	AnswerInput1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AnswerInput2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	NextButton.visible = false
	
	for a in answers:
		working_answers.append(a.duplicate())
	
	await run_elimination_phase()


func run_elimination_phase() -> void:
	var still_eliminating = true
	
	while still_eliminating:
		still_eliminating = false
		
		for i in range(questions.size()):
			current_question = i
			show_question_elimination(i)
			
			await get_tree().create_timer(0.5).timeout
			
			var options = working_answers[i]
			
			if options.size() > 1:
				still_eliminating = true
				
				var remove_index = randi() % options.size()
				await cross_out_answer(remove_index)
				options.remove_at(remove_index)
				
				await get_tree().create_timer(0.5).timeout
	
	final_answers.clear()
	for a in working_answers:
		final_answers.append(a[0])
	
	show_results()
					



func show_question_elimination(index: int):
	QuestionLabel.text = questions[index]
	
	var options = working_answers[index]
	var inputs = [AnswerInput1, AnswerInput2, AnswerInput3]
	var parent = AnswerInput1.get_parent()
	
	# Fill inputs with current options, empty the rest
	for i in range(inputs.size()):
		inputs[i].text = options[i] if i < options.size() else ""
	
	# Move populated inputs to top, empty ones to bottom
	var sorted = inputs.filter(func(n): return n.text != "")
	sorted += inputs.filter(func(n): return n.text == "")
	
	for input in sorted:
		parent.move_child(input, parent.get_child_count() - 1)
	
	reset_answer_styles()


# =========================
# ✂️ VISUAL EFFECTS
# =========================


func cross_out_answer(index: int) -> void:
	var labels = [AnswerInput1, AnswerInput2, AnswerInput3]
	
	if index >= labels.size():
		return
	
	var label = labels[index]
	
	# Fade it out instead
	label.modulate = Color(1, 1, 1, 0.0)
	
	await get_tree().create_timer(2.5).timeout


func reset_answer_styles():
	var labels = [AnswerInput1, AnswerInput2, AnswerInput3]
	
	for l in labels:
		if l.text != "":
			l.modulate = Color(1, 1, 1, 1)


# =========================
# 🎯 FINAL RESULTS
# =========================

func show_results():
	Perceiving1.visible = false
	Perceiving1.stop()
	QuestionAndAnswers.visible = false
	BackAndNext.visible = false
	RevealPanel.visible = true
	ResultsLabel.text = ""
	
	var answer_color = get_contrast_color(Background.color).to_html(false)
	var s = func(text: String) -> String:
		return "[color=#" + answer_color + "]" + text + "[/color]"
	
	var sentences = [
		s.call("In the future, you and ") + final_answers[0] + s.call(" will fall madly in love. "),
		s.call("The two of you will be married in ") + final_answers[1] + s.call(". "),
		s.call("As you walk down the aisle, \"") + final_answers[2] + s.call("\" will be playing. "),
		s.call("After the wedding, you will live together in ") + final_answers[3] + s.call(". "),
		s.call("Together, you will have ") + final_answers[4] + s.call(" children. "),
		final_answers[0] + s.call(" will lovingly call you \"") + final_answers[5] + s.call("\". "),
		s.call("Your favorite thing to do together will be ") + final_answers[6] + s.call(". "),
		s.call("You both agree that ") + final_answers[7] + s.call(" is the secret to true happiness."),
	]
	
	for sentence in sentences:
		ResultsLabel.text += sentence
		await get_tree().create_timer(3.5).timeout


func _on_quit_pressed() -> void:
	var menu_scene = load("res://main_menu.tscn")
	get_tree().change_scene_to_packed(menu_scene) # goes back to menu
