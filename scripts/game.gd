extends Node2D
	
	
func update_time() -> void:
	var hour = Singleton.get_hour()
	$ClockAnim.frame = hour if hour < 12 else hour - 12
	
	if hour < 4 or hour > 21:
		move_child($Night, 2)
	elif hour < 10 or hour > 16:
		move_child($Morning, 2)
	else:
		move_child($Day, 2)


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
	
	if Singleton.the_end:
		ending()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	Singleton.go_to("res://scenes/start.tscn")
	Singleton.clear()


var chooser_exists: bool = false
func _on_sleep_pressed() -> void:
	if not chooser_exists:
		chooser_exists = true
		
		var trans_but = Button.new()
		trans_but.size = Vector2(668, 868)
		trans_but.global_position = Vector2(-10, -10)
		
		var transparent: StyleBoxFlat = load("res://images/med/transparent.tres")
		trans_but.add_theme_stylebox_override('focus', transparent)
		trans_but.add_theme_stylebox_override('disabled', transparent)
		trans_but.add_theme_stylebox_override('hover_pressed', transparent)
		trans_but.add_theme_stylebox_override('hover', transparent)
		trans_but.add_theme_stylebox_override('pressed', transparent)
		trans_but.add_theme_stylebox_override('normal', transparent)
		add_child(trans_but)
		
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
			Singleton.add_time(sleep_chooser.value, false)
			update_labels()
		)
		
		var no: Button = Button.new()
		no.text = 'Нет'
		no.size = yes.size
		no.position = Vector2(360 + 44, 800)
		add_child(no)
		
		no.connect('button_up', func():
			remove_child(trans_but)
			remove_child(sleep_chooser)
			remove_child(ask)
			remove_child(yes)
			remove_child(no)
			chooser_exists = false
			sleep_chooser.free()
			ask.free()
			yes.free()
			trans_but.free()
		)
		
		trans_but.connect('button_down', func():
			remove_child(trans_but)
			remove_child(sleep_chooser)
			remove_child(ask)
			remove_child(yes)
			remove_child(no)
			chooser_exists = false
			sleep_chooser.free()
			ask.free()
			yes.free()
			no.free()
		)


func _on_gos_pressed() -> void:
	Singleton.go_to("res://scenes/gos_login.tscn")


func _on_5_pressed() -> void:
	Singleton.go_to("res://scenes/5.tscn")


func _on_work_pressed() -> void:
	Singleton.go_to("res://scenes/desktop.tscn")


func _on_fridge_pressed() -> void:
	Singleton.go_to("res://scenes/fridge.tscn")


func _on_med_but_pressed() -> void:
	var dark_but = Button.new()
	dark_but.size = Vector2(668, 868)
	dark_but.global_position = Vector2(-10, -10)
	
	var dark: StyleBoxFlat = load("res://images/med/dark.tres")
	var panel_style: StyleBoxFlat = load("res://images/med/ med_panel.tres")
	dark_but.add_theme_stylebox_override('focus', dark)
	dark_but.add_theme_stylebox_override('disabled', dark)
	dark_but.add_theme_stylebox_override('hover_pressed', dark)
	dark_but.add_theme_stylebox_override('hover', dark)
	dark_but.add_theme_stylebox_override('pressed', dark)
	dark_but.add_theme_stylebox_override('normal', dark)
	
	#for i in 
	for child in $Med/Scroll/MedV.get_children():
		child.queue_free()
	
	var ills: int = 0
	for i in Singleton.ills:
		var ill = Singleton.ills[i]
		if ill.active:
			ills += 1
			
			var title: Label = Label.new()
			title.text = ill.name
			title.add_theme_font_size_override('font_size', 30)
			title.add_theme_color_override('font_color', Color('#000000dd'))
			
			var desc: RichTextLabel = RichTextLabel.new()
			desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			desc.remove_child(desc.get_v_scroll_bar())
			desc.bbcode_enabled = true
			desc.add_theme_color_override('default_color', Color('#000000dd'))
			desc.add_theme_font_size_override('normal_font_size', 24)
			desc.text = ill.desc
			desc.custom_minimum_size.y = 5 * 38
			
			var v: VBoxContainer = VBoxContainer.new()
			v.add_child(title)
			v.add_child(desc)
			
			var panel: PanelContainer = PanelContainer.new()
			panel.custom_minimum_size = Vector2($Med/Scroll/MedV.size.x, 200)
			panel.add_theme_stylebox_override('panel', panel_style)
			panel.add_child(v)
			
			$Med/Scroll/MedV.add_child(panel)
	
	if ills == 0:
		var title: Label = Label.new()
		title.text = 'Вы столь здоровы, что вас бы даже не просили проходить медкомисию в Военкомате'
		title.add_theme_font_size_override('font_size', 30)
		title.add_theme_color_override('font_color', Color('#000000dd'))
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.custom_minimum_size.y = $Med/Scroll/MedV.size.y
		$Med/Scroll/MedV.add_child(title)
	
	$Med.global_position.x = get_window().size.x / 2
	
	dark_but.connect('button_down', func():
		remove_child(dark_but)
		$Med.global_position.x = 1500
	)
	
	add_child(dark_but)
	move_child($Med, -1)


func ending() -> void:
	print('конец')
