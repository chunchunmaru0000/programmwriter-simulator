extends Node2D
	
	
func update_time() -> void:
	var hour = Singleton.get_hour()
	$ClockAnim.frame = hour if hour < 12 else hour - 12


func update_labels() -> void:
	$StatsHBox/Info1LabelBox/Hp.text = str(Singleton.hp)
	$StatsHBox/Info1LabelBox/Money.text = str(Singleton.money)
	$StatsHBox/Info1LabelBox/Hunger.text = str(Singleton.hunger)
	$StatsHBox/Info1LabelBox/Thirst.text = str(Singleton.thirst)
	$StatsHBox/Info1LabelBox/Sleep.text = str(Singleton.sleep)
	
	update_time()
	$Time.text = "День " + str(Singleton.get_day()) + (".5" if Singleton.get_hour() > 12 else "")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	Singleton.go_to("res://scenes/start.tscn")


var chooser_exists: bool = false
func _on_sleep_pressed() -> void:
	if not chooser_exists:
		chooser_exists = true
		var ask: Label = Label.new()
		ask.text = "Спать\n" + str(1) + "час?"
		ask.position = Vector2(360, 746)
		ask.add_theme_font_size_override('font_size', 18)
		add_child(ask)
		
		var sleep_chooser: VScrollBar = VScrollBar.new()
		#sleep_chooser.size = Vector2(24, 24 * 24)
		#sleep_chooser.position = Vector2(448, 254)#566)
		sleep_chooser.size = Vector2(24, 24 * 12)
		sleep_chooser.position = Vector2(448, 254 + 24 * 12)#566)
		sleep_chooser.min_value = 1
		sleep_chooser.max_value = 25
		sleep_chooser.step = 1
		sleep_chooser.page = 1
		
		sleep_chooser.connect('value_changed', func(value: float):
			print(value)
			var chas: String = ''
			if sleep_chooser.value == 1 or sleep_chooser.value == 21:
				chas = 'час'
			elif (sleep_chooser.value > 1 and sleep_chooser.value < 5) or sleep_chooser.value > 21:
				chas = 'часа'
			elif sleep_chooser.value > 4 and sleep_chooser.value < 21:
				chas = 'часов'
			
			ask.text = "Спать\n" + str(sleep_chooser.value) + " " + chas + "?"
		)

		sleep_chooser.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
		sleep_chooser.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
		
		sleep_chooser.add_theme_stylebox_override('grabber', preload("res://pc_images/chrome/money/grabber_style.tres"))
		sleep_chooser.add_theme_stylebox_override('grabber_highlight', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
		sleep_chooser.add_theme_stylebox_override('grabber_pressed', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
		add_child(sleep_chooser)
		
		var yes: Button = Button.new()
		yes.text = 'Да'
		yes.size = Vector2(44, 20)
		yes.position = Vector2(360, 800)
		add_child(yes)
		yes.connect('button_up', func():
			var sleep_time = sleep_chooser.value
			Singleton.add_time(sleep_time)
			Singleton.add_sleep(-sleep_time * 2)

			update_labels()
		)
		
		var no: Button = Button.new()
		no.text = 'Нет'
		no.size = yes.size
		no.position = Vector2(360 + 44, 800)
		add_child(no)
		
		no.connect('button_up', func():
			remove_child(sleep_chooser)
			remove_child(ask)
			remove_child(yes)
			remove_child(no)
			chooser_exists = false
			sleep_chooser.free()
			ask.free()
			yes.free()
		)


func _on_gos_pressed() -> void:
	Singleton.go_to("res://scenes/gos_login.tscn")


func _on_5_pressed() -> void:
	Singleton.go_to("res://scenes/5.tscn")


func _on_work_pressed() -> void:
	Singleton.go_to("res://scenes/desktop.tscn")


func _on_fridge_pressed() -> void:
	Singleton.go_to("res://scenes/fridge.tscn")
