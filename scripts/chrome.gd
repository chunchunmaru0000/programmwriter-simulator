extends Node2D


class LangData:
	var exp: int
	var slash_n: bool
	var tabs: bool
	
	func _init(exp: int, slash_n: bool, tabs: bool) -> void:
		self.exp = exp
		self.slash_n = slash_n
		self.tabs = tabs


class Lang:
	var name: String
	var img: String
	var codes_paths: Array
	var learn_paths: Array
	var data: LangData
	
	func _init(name: String, img: String, codes_paths: Array, learn_paths: Array, data: LangData) -> void:
		self.name = name
		self.img = img
		self.codes_paths = codes_paths
		self.learn_paths = learn_paths
		self.data = data
		

class Task:
	var lang: Lang
	var path: String
	var code_name: int
	
	func _init(lang: Lang, path: String, code_name: int) -> void:
		self.lang = lang
		self.path = path
		self.code_name = code_name

var langs_names: PackedStringArray = DirAccess.open("res://langs/").get_directories()
var langs: Array = []
var levels_plus: int = 5


func get_datas_from_langs() -> void:
	if langs.size() == 0:
		for lang_name in langs_names:
			var lang_path: String = "res://langs/" + lang_name + "/"
			var codes_path: String = lang_path + "codes/"
			var learn_path: String = lang_path + "learn/"
			
			var data_text = FileAccess.open(lang_path + "data.txt", FileAccess.READ).get_as_text().split('\n')
			var lang_data: LangData = LangData.new(
				int(data_text[0].split('=')[1].strip_edges()),
				data_text[1].split('=')[1].strip_edges() == '1',
				data_text[2].split('=')[1].strip_edges() == '1'
			)
			
			var lang: Lang = Lang.new(
				lang_name,
				lang_path + "logo.png",
				Array(DirAccess.open(codes_path).get_files()).map(func(s): return codes_path + s),
				Array(DirAccess.open(learn_path).get_files()).map(func(s): return learn_path + s),
				lang_data
			)
			
			#print(lang.name)
			#print('exp=', lang_data.exp, ';slash_n=', lang_data.slash_n, ';tabs=', lang_data.tabs)
			#print(lang.codes_paths)
			#print(lang.learn_paths)
			langs.append(lang)


func get_new_panel(style: StyleBoxFlat, pos: String, padding: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override('panel', style)
	if pos == 'x':
		panel.custom_minimum_size.x = padding
	else:
		panel.custom_minimum_size.y = padding
	return panel


func draw_learn() -> void:
	$Background.texture = load("res://pc_images/chrome/learn/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
	
	for lang: Lang in langs:
		pass
	

func draw_money() -> void:
	$Background.texture = load("res://pc_images/chrome/money/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
	
	var tasks: Array = []
	
	for lang: Lang in langs:
		for code_path in lang.codes_paths:
			var text: String = code_path.split('/')[-1].split('.')[0].strip_edges()
			if text.is_valid_int():
				var code_name: int = int(text)
				if code_name / 3 <= lang.data.exp + levels_plus:
					tasks.append(Task.new(lang, code_path, code_name))
	
	tasks.sort_custom(func(a: Task, b: Task): return a.code_name < b.code_name)
	#print(tasks.map(func(task: Task): return task.code_name))
	
	var panel_style: StyleBoxFlat = preload("res://pc_images/chrome/money/offer_panel_style.tres")
	var block_style: StyleBoxFlat = preload("res://pc_images/chrome/money/panel_style.tres")
	var text_wide: int = 498
	var x_padding: int = 16
	var y_padding: int = 12
	var half_y_padding: int = y_padding / 2
	
	for task: Task in tasks:
		var datas = FileAccess.open(task.path, FileAccess.READ).get_as_text().split('\r\n<data///>\r\n')
		#print(datas)
		var title_text: String = datas[0]
		var desc_text: String = datas[1]
		var price_value: int = int(datas[2])
		var task_code_text: String = datas[3]
		
		
		var title: Label = Label.new()
		title.custom_minimum_size = Vector2(text_wide, 22)
		title.text = title_text
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.add_theme_color_override('font_color', Color('#009400'))
		title.add_theme_font_size_override('font_size', 20)
		
		
		var desc: Label = Label.new()
		desc.custom_minimum_size = Vector2(text_wide, 0)
		desc.text = desc_text
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_color_override('font_color', Color('#000000'))
		desc.add_theme_font_size_override('font_size', 14)
		
		
		var price_low: Label = Label.new()
		price_low.text = 'Бюджет: '
		price_low.add_theme_color_override('font_color', Color('#009400'))
		price_low.add_theme_font_size_override('font_size', 12)
		var price_big: Label = Label.new()
		price_big.text = str(price_value) + '₽'
		price_big.add_theme_color_override('font_color', Color('#009400'))
		price_big.add_theme_font_size_override('font_size', 20)
		var price: HBoxContainer = HBoxContainer.new()
		price.add_child(price_low)
		price.add_child(price_big)
		
		var vbox_labels: Label = Label.new()
		vbox_labels.text = \
			'Язык программирования: ' + task.lang.name + \
			'\nСтаж языка: ' + str(task.lang.data.exp) + \
			'\nСложность задания: ' + str(task.code_name)
		vbox_labels.add_theme_color_override('font_color', Color('#000000')) 
		vbox_labels.add_theme_font_size_override('font_size', 14)
		
		var icon: TextureRect = TextureRect.new()
		icon.texture = load(task.lang.img)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.custom_minimum_size = Vector2(64, 64)
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_child(icon)
		hbox.add_child(vbox_labels)
		
		var to_do_but: Button = Button.new()
		to_do_but.text = 'Выполнить задачу'
		to_do_but.alignment = HORIZONTAL_ALIGNMENT_CENTER
		to_do_but.custom_minimum_size.y = 40
		to_do_but.add_theme_color_override("font_color",  Color("#ffffff"))
		to_do_but.add_theme_color_override("font_hover_color",  Color("#ffffff"))
		to_do_but.add_theme_color_override("font_pressed_color",  Color("#ffffff"))
		to_do_but.add_theme_color_override("font_focus_color",  Color("#ffffff"))
		to_do_but.add_theme_stylebox_override('hover',         preload("res://pc_images/chrome/money/to_do_but_act.tres"))
		to_do_but.add_theme_stylebox_override('hover_pressed', preload("res://pc_images/chrome/money/to_do_but_act.tres"))
		to_do_but.add_theme_stylebox_override('pressed',       preload("res://pc_images/chrome/money/to_do_but_act.tres"))
		to_do_but.add_theme_stylebox_override('focus',         preload("res://pc_images/chrome/money/to_do_but_act.tres"))
		to_do_but.add_theme_stylebox_override('normal',        preload("res://pc_images/chrome/money/to_do_but_def.tres"))
		#to_do_but.connect("button_down", func(): eat_owned_product(eat_but, product))
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override('separation', 4)
		vbox.add_child(get_new_panel(block_style, 'y', y_padding))
		vbox.add_child(title)
		vbox.add_child(get_new_panel(block_style, 'y', half_y_padding))
		vbox.add_child(desc)
		vbox.add_child(get_new_panel(block_style, 'y', half_y_padding))
		vbox.add_child(price)
		vbox.add_child(hbox)
		vbox.add_child(get_new_panel(block_style, 'y', half_y_padding))
		vbox.add_child(to_do_but)
		vbox.add_child(get_new_panel(block_style, 'y', y_padding + half_y_padding))
		
		
		var panel: PanelContainer = PanelContainer.new()
		panel.add_theme_stylebox_override('panel', block_style)
		panel.add_child(vbox)
		panel.custom_minimum_size.x = $Scroll/Lenta.custom_minimum_size.x - $Scroll.get_v_scroll_bar().size.x - x_padding * 2
		
		var hgrid: HBoxContainer = HBoxContainer.new()
		var left: PanelContainer = get_new_panel(block_style, 'x', x_padding)
		var right: PanelContainer = get_new_panel(block_style, 'x', x_padding)
		
		hgrid.add_child(left)
		hgrid.add_child(panel)
		hgrid.add_child(right)
		
		var main_panel: PanelContainer = PanelContainer.new()
		main_panel.add_theme_stylebox_override('panel', panel_style)
		main_panel.add_child(hgrid)
		
		#$Scroll/Lenta.add_child(panel)
		$Scroll/Lenta.add_child(main_panel)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vbar: VScrollBar = $Scroll.get_v_scroll_bar()
	vbar.custom_minimum_size.x = 16
	vbar.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
	vbar.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
	
	vbar.add_theme_stylebox_override('grabber', preload("res://pc_images/chrome/money/grabber_style.tres"))
	vbar.add_theme_stylebox_override('grabber_highlight', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
	vbar.add_theme_stylebox_override('grabber_pressed', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
	
	get_datas_from_langs()
	var times = Singleton.time.split(':')
	$Time.text = times[1] + ':' + times[2]
	
	if Singleton.learn:
		$LearnBut.grab_focus()
		draw_learn()
	else:
		$MoneyBut.grab_focus()
		draw_money()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")


func _on_vs_button_down() -> void:
	Singleton.go_to("res://scenes/visual_studio.tscn")


func _on_esc_but_button_down() -> void:
	Singleton.go_to("res://scenes/desktop.tscn")


func _on_money_but_button_down() -> void:
	Singleton.learn = false
	draw_money()


func _on_learn_but_button_down() -> void:
	Singleton.learn = true
	draw_learn()
