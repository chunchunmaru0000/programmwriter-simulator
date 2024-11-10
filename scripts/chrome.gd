extends Node2D


class LangData:
	var exp: int
	var slash_n: bool
	var tabs: bool
	var did: Array
	var comment: String
	var super_comment: String
	
	func _init(exp: int, slash_n: bool, tabs: bool, did: Array, comment: String, super_comment: String) -> void:
		self.exp = exp
		self.slash_n = slash_n
		self.tabs = tabs
		self.did = did
		self.comment = comment
		self.super_comment = super_comment


class Lang:
	var name: String
	var img: CompressedTexture2D
	var codes_paths: Array
	var learn_paths: Array
	var data: LangData
	var data_path: String
	var desc: String
	var learns: Array
	var lights: Dictionary
	
	func _init(name: String, img: CompressedTexture2D, codes_paths: Array, learn_paths: Array, data: LangData, data_path: String, desc: String, learns: Array, lights: Dictionary) -> void:
		self.name = name
		self.img = img
		self.codes_paths = codes_paths
		self.learn_paths = learn_paths
		self.data = data
		self.data_path = data_path
		self.desc = desc
		self.learns = learns
		self.lights = lights
		

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
		self.id = id
		self.theme = theme
		self.text = text
		

var langs_names: PackedStringArray = DirAccess.open(Singleton.proj + "langs/").get_directories()
var langs: Array = []
var levels_plus: int = 5
var combo_box_learns: OptionButton

var all_tasks: Array
var combo_box_lan: OptionButton
var combo_box_hard: OptionButton
var combo_box_exp: OptionButton
var combo_box_money: OptionButton


func get_datas_from_langs() -> void:
	if langs.size() == 0:
		for lang_name in langs_names:
			var lang_path: String = Singleton.proj + "langs/" + lang_name + "/"
			var codes_path: String = lang_path + "codes/"
			var learn_path: String = lang_path + "learn/"
			var data_path: String = lang_path + "data.txt"
			
			var data_text = FileAccess.open(data_path, FileAccess.READ).get_as_text().split('\n')
			var lang_data: LangData
			
			var exp: int
			var did: Array
			
			if lang_name in Singleton.didexps:
				exp = Singleton.didexps[lang_name].exp
				did = [] if Singleton.didexps[lang_name].did == '' else Array(Singleton.didexps[lang_name].did.split('|')).map(func(num: String): return int(num))
			else:
				exp = 0
				did = []
				Singleton.didexps[lang_name] = Singleton.DidExp.new('', 0)
				
			lang_data = LangData.new(
				exp,
				data_text[0].split('=')[1].strip_edges() == '1',
				data_text[1].split('=')[1].strip_edges() == '1',
				did,
				data_text[2].split('=')[1].strip_edges(),
				data_text[3].split('=')[1].strip_edges()
			)
			
			var img = Image.new() 
			var texture = ImageTexture.new() 
			var file: FileAccess = FileAccess.open(lang_path + "logo.png", FileAccess.READ) 
			img.load_png_from_buffer(file.get_buffer(file.get_length())) 
			file.close() 
			
			#print(texture.get_size())
			if texture.get_size() == Vector2(0, 0):
				#print("res://reserve_langs/" + lang_name + "/logo.png", '   ', ResourceLoader.exists("res://reserve_langs/" + lang_name + "/logo.png"))
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
			
			var lights: Dictionary = {}
			for color in FileAccess.open(lang_path + "lights.txt", FileAccess.READ).get_as_text().replace('\r', '').split('\n[/color]\n'):
				var words = color.split('\n')
				
				for i in range(1, words.size()):
					if words[i] != '[/color]':
						lights[words[i]] = words[0]
				
			var lang: Lang = Lang.new(
				lang_name,
				texture,
				Array(DirAccess.open(codes_path).get_files()).map(func(s): return codes_path + s),
				Array(DirAccess.open(learn_path).get_files()).map(func(s): return learn_path + s),
				lang_data,
				data_path,
				FileAccess.open(lang_path + "desc.txt", FileAccess.READ).get_as_text(),
				sites,
				lights
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


func more_text(desc: RichTextLabel, title: LinkButton, more: LinkButton, line_size: int) -> void:
	desc.custom_minimum_size.y = desc.get_content_height()
	
	more.text = 'Свернуть'
	more.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	more.connect('button_down',    func(): less_text(desc, title, more, line_size))
	title.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	title.connect('button_down',    func(): less_text(desc, title, more, line_size))
	
	
func less_text(desc: RichTextLabel, title: LinkButton, more: LinkButton, line_size: int) -> void:
	desc.custom_minimum_size.y = 3 * line_size
	
	more.text = 'Подробнее'
	more.button_down
	more.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	more.connect('button_down',    func(): more_text(desc, title, more, line_size))
	title.disconnect('button_down', more.get_signal_connection_list('button_down')[0]['callable'])
	title.connect('button_down',    func(): more_text(desc, title, more, line_size))


class Tokenizator:
	var lang: Lang
	var code: String
	var comment: String
	var pos: int
	var no_need: Array
	
	var check_comment: bool
	var long_comment: bool
	
	var check_super_comment: bool
	var super_comment_l: String
	var super_comment_r: String
	var inside_super_comment: bool
	
	func remove_from_arr_str(arr: Array, string: String) -> Array:
		for j in string.length():
			for i in arr.size():
				if arr[i] == string[j]:
					arr.remove_at(i)
					break
		return arr

	func _init(code: String, lang: Lang) -> void:
		self.lang = lang
		self.code = code
		self.comment = lang.data.comment
		self.pos = 0
		
		self.no_need = [
			' ', '\t', '\n', '+', '-', '*', '=', '/', '%', '[', ']', '(', ')', '{', '}',
			'|', '$', '&', '@', ';', ',', '.', ':', '?', '<', '>', '!', '#'
		]
		
		if lang.data.super_comment == '':
			check_super_comment = false
		else:
			check_super_comment = true
			var super_comment: Array = lang.data.super_comment.split(' ')
			super_comment_l = super_comment[0]
			super_comment_r = super_comment[1]
			
			no_need = remove_from_arr_str(no_need, super_comment_l)
			no_need = remove_from_arr_str(no_need, super_comment_r)
		inside_super_comment = false
		
		if comment == '':
			check_comment = false
		else:
			check_comment = true
			if comment.length() > 1:
				long_comment = true
			else:
				long_comment = false
			no_need = remove_from_arr_str(no_need, comment)
				
		
	func current() -> String:
		if pos < code.length():
			return code[pos]
		return '<эээ///>'
		
	func next() -> void:
		pos += 1
	
	func next_token() -> String:
		if current() == '<эээ///>':
			return '<эээ///>'
		var begin: int = pos
		if check_comment:
			if long_comment:
				if pos + comment.length() < code.length():
					if code.substr(pos, comment.length()) == comment:
						pos += comment.length()
						while not current() in ['\n', '<эээ///>']:
							next()
							
						return '[color=#008200]' + code.substr(begin, pos - begin) + '[/color]'
			else:
				if current() == comment:
					while not current() in ['\n', '<эээ///>']:
						next()
					return '[color=#008200]' + code.substr(begin, pos - begin) + '[/color]'
					
		if check_super_comment:
			if pos + super_comment_l.length() < code.length():
				if code.substr(pos, super_comment_l.length()) == super_comment_l:
					pos += comment.length()
					inside_super_comment = true
					return super_comment_l
			if pos + super_comment_r.length() < code.length():
				if code.substr(pos, super_comment_r.length()) == super_comment_r:
					pos += comment.length()
					inside_super_comment = false
					return super_comment_r
					
		if current() in no_need:
			while current() in no_need:
				next()
			return code.substr(begin, pos - begin)
		if current() == '"':
			next()
			var buffer: String = '"'
			while current() != '"':
				buffer += current()
				if current() == '\\':
					next()
					if current() == '<эээ///>':
						return buffer
					elif current() == '"':
						next()
						buffer += '"'
				else:
					next()
			next()
			buffer += '"'
			return buffer if inside_super_comment else '[color=#ffeda0]' + buffer + '[/color]' 
		if current() == '`':
			next()
			var buffer: String = '`'
			while current() != '`':
				buffer += current()
				if current() == '\\':
					next()
					if current() == '<эээ///>':
						return buffer
					elif current() == '`':
						next()
						buffer += '`'
				else:
					next()
			next()
			buffer += '`'
			return buffer if inside_super_comment else '[color=#ffeda0]' + buffer + '[/color]'
		if current() == "'":
			next()
			var buffer: String = "'"
			while current() != "'":
				buffer += current()
				if current() == '\\':
					next()
					if current() == '<эээ///>':
						return buffer
					elif current() == "'":
						next()
						buffer += "'"
				else:
					next()
			next()
			buffer += "'"
			return buffer if inside_super_comment else '[color=#ffeda0]' + buffer + '[/color]'
		if current().is_valid_int():
			while current().is_valid_int() or current() == '.':
				next() 
			var surstr: String = code.substr(begin, pos - begin)
			return surstr if inside_super_comment else '[color=#a0ffe0]' + surstr + '[/color]'
		if current().is_valid_identifier():
			while current().is_valid_identifier() or current().is_valid_int():
				next()
			return code.substr(begin, pos - begin)
		else:
			var char: String = current()
			next()
			return char
			
	func tokenize() -> String:
		var tokens: Array = []
		var token = next_token()
		while token != '<эээ///>':
			tokens.append(token)
			token = next_token()
		
		var i: int = -1
		while i < tokens.size() - 1:
			i += 1
		#for i in tokens.size():
			if tokens[i] == super_comment_l:
				tokens[i] = '[color=#008200]' + tokens[i]
				while tokens[i] != super_comment_r or i == tokens.size() - 1:
					i += 1
				if tokens[i] == super_comment_r:
					tokens[i] = tokens[i] + '[/color]'
					i += 1
				continue
			if tokens[i] in lang.lights:
				tokens[i] = lang.lights[tokens[i]] + tokens[i] + '[/color]'

		return ''.join(tokens)


func do_some_text_magic(text: String, lang: Lang) -> String:
	var blocks = text.split('<code///>')
	if blocks.size() < 2:
		return text
	
	for block in range(1, blocks.size(), 2):
		blocks[block] = Tokenizator.new(blocks[block], lang).tokenize()
		
	return ''.join(blocks)


func draw_lang_learn(lang: Lang) -> void:
	for child in $Scroll/Lenta.get_children():
		if child.name != 'google':
			$Scroll/Lenta.remove_child(child)
			child.queue_free()
			
	combo_box_learns.clear()
	
	var site_block_style: StyleBoxFlat = preload("res://pc_images/chrome/learn/block_style.tres")
	var text_wide: int = 498
	var x_padding: int = 16
	var y_padding: int = 12
	var half_y_padding: int = y_padding / 2
	lang.learns.sort_custom(func(a: Site, b: Site): return a.id < b.id)
	for site: Site in lang.learns:
		combo_box_learns.add_item(str(site.id) + '.' + site.theme)
		
		var icon: TextureRect = TextureRect.new()
		icon.texture = lang.img
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.custom_minimum_size = Vector2(32, 24)
		
		var name_link: Label = Label.new()
		name_link.text = \
			lang.name.to_lower().replace(' ', '_') + '.org\n' + \
			'https://www.' + lang.name.to_lower().replace(' ', '_') + '/' + site.theme.to_lower().replace(' ', '_') + '.org > doc\n'
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

		var desc: RichTextLabel = RichTextLabel.new()
		desc.remove_child(desc.get_v_scroll_bar())
		desc.bbcode_enabled = true
		var desc_line_size: int = 20
		
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_color_override('default_color', Color('#bfbfbf'))
		desc.add_theme_font_size_override('normal_font_size', 14)
		desc.custom_minimum_size.y = 3 * desc_line_size
		#desc.max_lines_visible = 3
		desc.text = do_some_text_magic(site.text.replace('\r', ''), lang)
		#desc.text = do_some_text_magic(site.text.replace('\r', ''), lang.lights)#site.text.replace('print', "[color=#6696ff]print[/color]")
		
		var more: LinkButton = LinkButton.new()
		more.text = "Подробнее"
		more.add_theme_color_override('font_color', Color('#94bcf6'))
		more.add_theme_color_override('font_focus_color', Color('#c07ddd'))
		more.add_theme_color_override('font_pressed_color', Color('#c07ddd'))
		more.add_theme_color_override('font_hover_color', Color('#c07ddd'))
		more.add_theme_color_override('font_hover_pressed_color', Color('#c07ddd'))
		more.add_theme_font_size_override('font_size', 12)
		more.connect('button_down', func(): more_text(desc, title, more, desc_line_size))
		title.connect('button_down', func(): more_text(desc, title, more, desc_line_size))
		
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override('separation', 4)
		vbox.add_child(hup)
		vbox.add_child(title)
		vbox.add_child(desc)
		vbox.add_child(more)
		vbox.add_child(get_new_panel(site_block_style, 'y', y_padding + half_y_padding))
		
		var panel: PanelContainer = PanelContainer.new()
		panel.add_theme_stylebox_override('panel', site_block_style)
		panel.add_child(vbox)
		panel.custom_minimum_size.x = $Scroll/Lenta.custom_minimum_size.x - $Scroll.get_v_scroll_bar().size.x - x_padding * 2
		
		var hgrid: HBoxContainer = HBoxContainer.new()
		var left: PanelContainer = get_new_panel(site_block_style, 'x', x_padding)
		
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
	combo_box.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
	combo_box.add_theme_font_size_override('font_size', 12)
	combo_box.position = Vector2(150, 30)
	combo_box.custom_minimum_size.x = 69
	combo_box.add_theme_stylebox_override('normal', combo_box_style)
	combo_box.connect('item_selected', 
		func(index: int): draw_lang_learn(langs.filter(
			func(lang: Lang): return lang.name == combo_box.text)[0]
		)
	)
	
	combo_box_learns = OptionButton.new() 
	combo_box_learns.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
	combo_box_learns.add_theme_font_size_override('font_size', 12)
	combo_box_learns.position = Vector2(315, 30)
	combo_box_learns.custom_minimum_size.x = 90
	combo_box_learns.add_theme_stylebox_override('normal', combo_box_style)
	combo_box_learns.connect('item_selected', 
		func(index: int): 
			var needed_node: HBoxContainer
			for node in $Scroll/Lenta.get_children():
				if node.name == '.'.join(combo_box_learns.text.split('.').slice(1)):
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
	

func decide_tasks() -> void:
	var tasks: Array = all_tasks.duplicate(true)
	
	if not combo_box_lan.text == 'Любой':
		tasks = tasks.filter(func(task: Task): return task.lang.name == combo_box_lan.text)
	
	if not combo_box_hard.text == 'Любая':
		tasks = tasks.filter(func(task: Task): return str(task.code_name) == combo_box_hard.text)
		
	if not combo_box_exp.text == 'Любой':
		tasks = tasks.filter(func(task: Task): return str(task.lang.data.exp) == combo_box_exp.text)
	
	if not combo_box_money.text == 'Любой':
		match combo_box_money.text:
			'от 0 до 100':
				tasks = tasks.filter(func(task: Task): return task.price < 101)
			'от 101 до 500':
				tasks = tasks.filter(func(task: Task): return task.price > 100 and task.price < 501) 
			'от 501 до 1000':
				tasks = tasks.filter(func(task: Task): return task.price > 500 and task.price < 1001) 
			'от 1001 до 10000':
				tasks = tasks.filter(func(task: Task): return task.price > 1000 and task.price < 10001) 
			'от 10001 и более':
				tasks = tasks.filter(func(task: Task): return task.price > 10000)
				
	draw_money_of(tasks)


func do_combo_box() -> OptionButton:
	var combo_box_style: StyleBoxFlat = preload("res://pc_images/chrome/money/offer_panel_style.tres")
	var combo_box = OptionButton.new()
	combo_box.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
	combo_box.add_theme_font_size_override('font_size', 14)
	combo_box.add_theme_color_override('font_color', Color('#000000'))
	combo_box.add_theme_color_override('font_focus_color', Color('#000000'))
	
	combo_box.custom_minimum_size.x = 400
	combo_box.add_theme_stylebox_override('normal', combo_box_style)
	combo_box.connect('item_selected', func(index: int): decide_tasks())
	return combo_box
	

func do_label(text: String, font_size: int=14, color: Color=Color('#000000')) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override('font_color', color)
	label.add_theme_font_size_override('font_size', font_size)
	return label
	

func do_box(type, children: Array):
	var box = type.new()
	for child in children:
		box.add_child(child)


func draw_money() -> void:
	var tasks: Array = []
	
	for lang: Lang in langs:
		for code_path in lang.codes_paths:
			var text: String = code_path.split('/')[-1].split('.')[0].strip_edges()
			if text.is_valid_int():
				var code_name: int = int(text)
				if code_name <= lang.data.exp + levels_plus:
					tasks.append(Task.new(lang, code_path, code_name))
	tasks.sort_custom(func(a: Task, b: Task): return a.code_name < b.code_name)
	all_tasks = tasks
	
	var text_wide: int = 498
	var x_padding: int = 16
	var y_padding: int = 12
	var half_y_padding: int = y_padding / 2
	
	$Background.texture = preload("res://pc_images/chrome/money/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
		
	var panel_style: StyleBoxFlat = preload("res://pc_images/chrome/money/offer_panel_style.tres")
	var block_style: StyleBoxFlat = preload("res://pc_images/chrome/money/panel_style.tres")
	var combo_box_style: StyleBoxFlat = panel_style
	
	var title: Label = do_label('Фильтры', 26)
	title.custom_minimum_size = Vector2(text_wide, 30)
	
	
	combo_box_lan = do_combo_box()
	var hbox_lan: HBoxContainer = HBoxContainer.new()
	hbox_lan.add_child(do_label("Язык: "))
	hbox_lan.add_child(combo_box_lan)
	
	combo_box_hard = do_combo_box()
	var hbox_hard: HBoxContainer = HBoxContainer.new()
	hbox_hard.add_child(do_label("Сложность: "))
	hbox_hard.add_child(combo_box_hard)
	
	combo_box_exp = do_combo_box()
	var hbox_exp: HBoxContainer = HBoxContainer.new()
	hbox_exp.add_child(do_label("Стаж языка: "))
	hbox_exp.add_child(combo_box_exp)
	
	combo_box_money = do_combo_box()
	var hbox_money: HBoxContainer = HBoxContainer.new()
	hbox_money.add_child(do_label("Бюджет: "))
	hbox_money.add_child(combo_box_money)
	
	var v_fils: VBoxContainer = VBoxContainer.new()
	v_fils.add_child(get_new_panel(block_style, 'y', y_padding))
	v_fils.add_child(title)
	v_fils.add_child(hbox_lan)
	v_fils.add_child(hbox_hard)
	v_fils.add_child(hbox_exp)
	v_fils.add_child(hbox_money)
	v_fils.add_child(get_new_panel(block_style, 'y', y_padding + half_y_padding))
	
	var temp: Array = []
	combo_box_lan.add_item("Любой")
	for lang: Lang in langs:
		combo_box_lan.add_item(lang.name)
	
		if not lang.data.exp in temp:
			temp.append(lang.data.exp)
	
	temp.sort_custom(func(a, b): return a < b)
	combo_box_exp.add_item("Любой")
	for exp in temp:
		combo_box_exp.add_item(str(exp))
		
	temp.clear()
	for task: Task in tasks:
		if not task.code_name in temp:
			temp.append(task.code_name)
	
	temp.sort_custom(func(a, b): return a < b)
	combo_box_hard.add_item("Любая")
	for hard in temp:
		combo_box_hard.add_item(str(hard))
		
	temp = ['Любой', 'от 0 до 100', 'от 101 до 500', 'от 501 до 1000', 'от 1001 до 10000', 'от 10001 и более']
	for b in temp:
		combo_box_money.add_item(b)
	
	var filters: PanelContainer = PanelContainer.new()
	filters.add_theme_stylebox_override('panel', block_style)
	filters.custom_minimum_size.x = $Scroll/Lenta.custom_minimum_size.x - $Scroll.get_v_scroll_bar().size.x - x_padding * 2
	filters.add_child(v_fils)
	
	var hgrid: HBoxContainer = HBoxContainer.new()
	var left: PanelContainer = get_new_panel(block_style, 'x', x_padding)
	var right: PanelContainer = get_new_panel(block_style, 'x', x_padding)
	
	hgrid.add_child(left)
	hgrid.add_child(filters)
	hgrid.add_child(right)
	
	var main_panel: PanelContainer = PanelContainer.new()
	main_panel.add_theme_stylebox_override('panel', panel_style)
	main_panel.add_child(hgrid)
	main_panel.name = 'filters'
	$Scroll/Lenta.add_child(main_panel)
	
	decide_tasks()


func draw_money_of(tasks: Array) -> void:
	for child in $Scroll/Lenta.get_children():
		if child.name != 'filters':
			$Scroll/Lenta.remove_child(child)
			child.queue_free()
	
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
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.text = desc_text
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
