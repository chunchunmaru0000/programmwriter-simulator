extends Node2D


class LangData:
	var exp: int
	var slash_n: bool
	var tabs: bool
	var did: Array
	
	func _init(exp: int, slash_n: bool, tabs: bool, did: Array) -> void:
		self.exp = exp
		self.slash_n = slash_n
		self.tabs = tabs
		self.did = did


class Lang:
	var name: String
	var img: CompressedTexture2D
	var codes_paths: Array
	var learn_paths: Array
	var data: LangData
	var data_path: String
	var desc: String
	var learns: Array
	
	func _init(name: String, img: CompressedTexture2D, codes_paths: Array, learn_paths: Array, data: LangData, data_path: String, desc: String, learns: Array) -> void:
		self.name = name
		self.img = img
		self.codes_paths = codes_paths
		self.learn_paths = learn_paths
		self.data = data
		self.data_path = data_path
		self.desc = desc
		self.learns = learns
		

class Task:
	var lang: Lang
	var path: String
	var code_name: int
	var price: int
	
	func _init(lang: Lang, path: String, code_name: int, price: int=0) -> void:
		self.lang = lang
		self.path = path
		self.code_name = code_name
		self.price = price
		

class Site:
	var id: int
	var theme: String
	var text: String
	
	func _init(id: int, theme: String, text: String) -> void:
		self.theme = theme
		self.text = text
		

var langs_names: PackedStringArray = DirAccess.open(Singleton.proj + "langs/").get_directories()
var langs: Array = []
var levels_plus: int = 5
var combo_box_learns: OptionButton


func get_datas_from_langs() -> void:
	if langs.size() == 0:
		for lang_name in langs_names:
			var lang_path: String = Singleton.proj + "langs/" + lang_name + "/"
			var codes_path: String = lang_path + "codes/"
			var learn_path: String = lang_path + "learn/"
			var data_path: String = lang_path + "data.txt"
			
			var data_text = FileAccess.open(data_path, FileAccess.READ).get_as_text().split('\n')
			
			var lang_data: LangData = LangData.new(
				int(data_text[0].split('=')[1].strip_edges()),
				data_text[1].split('=')[1].strip_edges() == '1',
				data_text[2].split('=')[1].strip_edges() == '1',
				[] if data_text[3] == 'did=' else Array(data_text[3].split('=')[1].split('|')).map(func(num: String): return int(num))
			)
			
			var img = Image.new() 
			var texture = ImageTexture.new() 
			var file: FileAccess = FileAccess.open(lang_path + "logo.png", FileAccess.READ) 
			img.load_png_from_buffer(file.get_buffer(file.get_length())) 
			file.close() 
			
			print(texture.get_size())
			if texture.get_size() == Vector2(0, 0):
				print("res://reserve_langs/" + lang_name + "/logo.png", '   ', ResourceLoader.exists("res://reserve_langs/" + lang_name + "/logo.png"))
				if ResourceLoader.exists("res://reserve_langs/" + lang_name + "/logo.png"):
					texture = load("res://reserve_langs/" + lang_name + "/logo.png")
			
			var sites: Array = []
			for site_name in DirAccess.open(lang_path + "learn/").get_files():
				var spl = site_name.split('.')
				sites.append(Site.new(
					int(spl[0]),
					'.'.join(spl.slice(1, -1)),
					FileAccess.open(lang_path + "learn/" + site_name, FileAccess.READ).get_as_text()
				))
			sites.sort_custom(func(a: Site, b: Site): return a.id < b.id)
			
			var lang: Lang = Lang.new(
				lang_name,
				texture,
				Array(DirAccess.open(codes_path).get_files()).map(func(s): return codes_path + s),
				Array(DirAccess.open(learn_path).get_files()).map(func(s): return learn_path + s),
				lang_data,
				data_path,
				FileAccess.open(lang_path + "desc.txt", FileAccess.READ).get_as_text(),
				sites
			)
			langs.append(lang)


func get_new_panel(style: StyleBoxFlat, pos: String, padding: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override('panel', style)
	if pos == 'x':
		panel.custom_minimum_size.x = padding
	else:
		panel.custom_minimum_size.y = padding
	return panel


func take_task(task: Task) -> void:
	Singleton.task_path = task.path
	Singleton.tabs = task.lang.data.tabs
	Singleton.slash_n = task.lang.data.slash_n
	Singleton.task = task
	Singleton.did_task = false
	Singleton.go_to("res://scenes/visual_studio.tscn")


func draw_learn_site(site: Site, lang_was: Lang) -> void:
	#тут короче сделать просто больше текст можно попробовать, а не новую страницу
	#типа как показать больше, как разворачиваются статьи на википедии
	pass


func more_text(desc: Label, more: LinkButton) -> void:
	desc.max_lines_visible = desc.get_line_count()
	desc.custom_minimum_size.y = desc.max_lines_visible * 15
	
	more.text = 'Свернуть'
	more.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	more.connect('button_down',    func(): less_text(desc, more))
	
	
func less_text(desc: Label, more: LinkButton) -> void:
	desc.max_lines_visible = 3
	desc.custom_minimum_size.y = desc.max_lines_visible * 15
	
	more.text = 'Подробнее'
	more.button_down
	more.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	more.connect('button_down',    func(): more_text(desc, more))


func draw_lang_learn(lang: Lang) -> void:
	for child in $Scroll/Lenta.get_children():
		if child.name != 'google':
			$Scroll/Lenta.remove_child(child)
			child.queue_free()
			
	combo_box_learns.clear()

	var block_style: StyleBoxFlat = preload("res://pc_images/chrome/learn/block_style.tres")
	var text_wide: int = 498
	var x_padding: int = 16
	var y_padding: int = 12
	var half_y_padding: int = y_padding / 2
	
	for site: Site in lang.learns:
		combo_box_learns.add_item(site.theme)
		
		var icon: TextureRect = TextureRect.new()
		icon.texture = lang.img
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.custom_minimum_size = Vector2(32, 24)
		
		var name_link: Label = Label.new()
		name_link.text = \
			lang.name + '.org\n' + \
			'https://www.' + lang.name.to_lower() + '/' + site.theme + '.org > doc\n'
		name_link.add_theme_color_override('font_color', Color('#bfbfbf'))
		name_link.add_theme_font_size_override('font_size', 11)
		
		var hup: HBoxContainer = HBoxContainer.new()
		hup.add_child(icon)
		hup.add_child(name_link)
		
		var title: LinkButton = LinkButton.new()
		title.text = site.theme + " - Документация по " + lang.name
		title.add_theme_color_override('font_color', Color('#94bcf6'))
		title.add_theme_color_override('font_focus_color', Color('#c07ddd'))
		title.add_theme_color_override('font_pressed_color', Color('#c07ddd'))
		title.add_theme_color_override('font_hover_color', Color('#c07ddd'))
		title.add_theme_color_override('font_hover_pressed_color', Color('#c07ddd'))
		title.add_theme_font_size_override('font_size', 18)
		title.connect('button_down', func(): print(title.text))#draw_learn_site(site, lang))

		var desc: Label = Label.new()
		desc.text = site.text#lang.desc
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_color_override('font_color', Color('#bfbfbf'))
		desc.add_theme_font_size_override('font_size', 14)
		desc.max_lines_visible = 3
		
		var more: LinkButton = LinkButton.new()
		more.text = "Подробнее"
		more.add_theme_color_override('font_color', Color('#94bcf6'))
		more.add_theme_color_override('font_focus_color', Color('#c07ddd'))
		more.add_theme_color_override('font_pressed_color', Color('#c07ddd'))
		more.add_theme_color_override('font_hover_color', Color('#c07ddd'))
		more.add_theme_color_override('font_hover_pressed_color', Color('#c07ddd'))
		more.add_theme_font_size_override('font_size', 12)
		more.connect('button_down', func(): more_text(desc, more))
		
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override('separation', 4)
		vbox.add_child(hup)
		vbox.add_child(title)
		vbox.add_child(desc)
		vbox.add_child(more)
		vbox.add_child(get_new_panel(block_style, 'y', y_padding + half_y_padding))
		
		var panel: PanelContainer = PanelContainer.new()
		panel.add_theme_stylebox_override('panel', block_style)
		panel.add_child(vbox)
		panel.custom_minimum_size.x = $Scroll/Lenta.custom_minimum_size.x - $Scroll.get_v_scroll_bar().size.x - x_padding * 2
		
		var hgrid: HBoxContainer = HBoxContainer.new()
		var left: PanelContainer = get_new_panel(block_style, 'x', x_padding)
		
		hgrid.add_child(left)
		hgrid.add_child(panel)
		hgrid.name = site.theme
		
		$Scroll/Lenta.add_child(hgrid)


func draw_learn() -> void:
	$Background.texture = preload("res://pc_images/chrome/learn/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
	
	var google: TextureRect = TextureRect.new()
	google.texture = preload("res://pc_images/chrome/learn/google.png")
	google.name = 'google'
	google.custom_minimum_size.x = $Scroll/Lenta.custom_minimum_size.x
	google.custom_minimum_size.y = 80
	google.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Scroll/Lenta.add_child(google)
	
	var combo_box_style: StyleBoxFlat = load("res://pc_images/chrome/learn/combo_box_def.tres")
	var combo_box: OptionButton = OptionButton.new() 
	combo_box.add_theme_font_size_override('font_size', 12)
	combo_box.position = Vector2(150, 30)
	combo_box.custom_minimum_size.x = 80
	combo_box.add_theme_stylebox_override('normal', combo_box_style)
	combo_box.connect('item_selected', 
		func(index: int): draw_lang_learn(langs.filter(
			func(lang: Lang): return lang.name == combo_box.text)[0]
		)
	)
	
	combo_box_learns = OptionButton.new() 
	combo_box_learns.add_theme_font_size_override('font_size', 12)
	combo_box_learns.position = Vector2(330, 30)
	combo_box_learns.custom_minimum_size.x = 80
	combo_box_learns.add_theme_stylebox_override('normal', combo_box_style)
	combo_box_learns.connect('item_selected', 
		func(index: int): 
			var needed_node: HBoxContainer
			for node in $Scroll/Lenta.get_children():
				if node.name == combo_box_learns.text:
					needed_node = node
					break
			$Scroll/Lenta.move_child(needed_node, 1)
	)
	
	langs.sort_custom(func(a: Lang, b: Lang): return a.data.exp > b.data.exp)
	for lang: Lang in langs:
		combo_box.add_item(lang.name)
		
	google.add_child(combo_box)
	google.add_child(combo_box_learns)
	
	if langs.size() > 0:
		draw_lang_learn(langs[0])
	

func draw_money() -> void:
	$Background.texture = preload("res://pc_images/chrome/money/back.png")
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
		if task.code_name in task.lang.data.did:
			continue
		
		var datas = FileAccess.open(task.path, FileAccess.READ).get_as_text().split('\r\n<data///>\r\n')
		var title_text: String = datas[0]
		var desc_text: String = datas[1]
		var price_value: int = int(datas[2])
		var task_code_text: String = datas[3]
		task.price = price_value
		
		
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
		icon.texture = task.lang.img
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
		to_do_but.connect("button_down", func(): take_task(task))
		
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
