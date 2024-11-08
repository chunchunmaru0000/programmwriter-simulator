extends Node2D


var rnd = RandomNumberGenerator.new()

var from: Button = null
var to: Button = null
var holder0: Button = null

var text: String = '' if Singleton.did_task else FileAccess.open(Singleton.task_path, FileAccess.READ).get_as_text().split('\r\n<data///>\r\n')[-1]
var text_bez_n = text.replace('<n///>', '')
var strokes: PackedStringArray = text_bez_n.split('\n')

func estimate_code() -> bool:
	if Singleton.did_task:
		return false
		
	var equal: bool = false
	
	var lines = text.split('\n')
	var words: Array = []
	var buts: Array = []
	
	for line in lines:
		for word in line.split('<w///>'):
			var stripped_word = word.strip_edges()
			if stripped_word != '' and stripped_word != '\n':
				words.append(stripped_word.replace('<n///>', ''))
				
				if stripped_word.contains('<n///>'):
					words.append('<n///>')
	
	if Singleton.slash_n and Singleton.tabs:	
		for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
			var hcont: HBoxContainer = panel.get_child(0)
			for but: Button in hcont.get_children():
				var stripped_but: String = but.text.strip_edges()
				if stripped_but == '' and but.text.length() == 12:
					buts.append('<t///>')
				else:
					buts.append(stripped_but)
			buts.append('<n///>')
		equal = \
			Array(''.join(words).split('<n///>')).filter(func(word): return word != '') == \
			Array(''.join(buts).split('<n///>')).filter(func(word):  return word != '')

#elif not Singleton.slash_n and Singleton.tabs:
	# вероятно не существует
		
	elif Singleton.slash_n and not Singleton.tabs:	
		for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
			var hcont: HBoxContainer = panel.get_child(0)
			for but: Button in hcont.get_children():
				buts.append(but.text.strip_edges())
			buts.append('<n///>')
		equal = \
			Array(''.join(words).split('<n///>')). \
				filter(func(word): return word != '' and word != '<t///>'). \
				map(func(word): return word.replace('<t///>', '')) == \
			Array(''.join(buts).split('<n///>')).filter(func(word):  return word != '')

	else:
		buts = $ScrollContainer/VBoxContainer.get_children(). \
			map(func(panel: PanelContainer): return panel.get_child(0).get_children(). \
			map(func(but: Button): return but.text.strip_edges().replace('\n', '')))
		equal = \
			''.join(words.map(func(word): return word.replace('<t///>', ''))) == \
			''.join(buts.map(func(line): return ''.join(line)))
		
	print(equal)
	return equal


func swap_from_to(sender: Button) -> void:
	if from == null:
		from = sender
	else:
		to = sender

		var from_parrent: HBoxContainer = from.get_parent()
		var to_parrent: HBoxContainer = to.get_parent()
		
		var from_place: int = child_place(from, from_parrent)
		var to_place: int = child_place(to, to_parrent)
		
		from_parrent.remove_child(from)
		to_parrent.remove_child(to)
		
		from_parrent.add_child(to)
		to_parrent.add_child(from)
		
		from_parrent.move_child(to, from_place)
		to_parrent.move_child(from, to_place)
		
		from = null
		to = null


func but_m_pos(sender: Button) -> Vector2:
	var m_pos: Vector2 = get_global_mouse_position()
	var s_cms: Vector2 = sender.custom_minimum_size
	return Vector2(m_pos.x - (s_cms.x / 2), m_pos.y - (s_cms.y / 2))


func but_add_themes(but: Button) -> void:
	but.add_theme_color_override("font_color",  Color("#000000"))
	but.add_theme_color_override("font_hover_color",  Color("#000000"))
	but.add_theme_color_override("font_pressed_color",  Color("#000000"))
	but.add_theme_color_override("font_focus_color",  Color("#000000"))

	but.add_theme_stylebox_override('hover', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('hover_pressed', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('pressed', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('focus', load("res://pc_images/vs/hover_flat.tres"))

	but.add_theme_stylebox_override('normal', load("res://pc_images/vs/normal_flat.tres"))


func clone_but(sender: Button) -> Button:
	var clone: Button = Button.new()
	clone.text = sender.text
	clone.custom_minimum_size = sender.size
	but_add_themes(clone)
	return clone


func child_place(sender: Button, parrent: HBoxContainer) -> int:
	var place: int = 0
	for child in parrent.get_children():
		if child == sender:
			break
		place += 1
	return place


func but_up(sender: Button) -> void:
	remove_child(holder0)
	
	var was_any: bool = false
	var m_pos: Vector2 = get_global_mouse_position()
	var gap_y2: int = $ScrollContainer/VBoxContainer.get_theme_constant('separation') / 2
	var more_than_last_but_width: bool = false
	
	for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
		var hbox: HBoxContainer = panel.get_child(0)
		if was_any: break
		var gap_x: int = hbox.get_theme_constant('separation') # / 2
		var place: int = 0
		var og: Vector2 = hbox.get_global_transform().origin
		
		if og.y - gap_y2 <= m_pos.y and og.y + hbox.size.y + gap_y2 >= m_pos.y:
			var to_place = func():
				from.get_parent().remove_child(from)
				hbox.add_child(from)
			
			if hbox.get_child_count() < 1:
				to_place.call()
			elif m_pos.x > hbox.get_children()[hbox.get_child_count() - 1].global_position.x + hbox.get_children()[hbox.get_child_count() - 1].size.x:
				to_place.call()
			elif m_pos.x < og.x:
				to_place.call()
				hbox.move_child(from, 0)
			else:
				for but: Button in hbox.get_children():
					var pos: Vector2 = but.global_position
					var b_s: Vector2 = but.size
					
					if pos.x <= m_pos.x and pos.x + b_s.x >= m_pos.x:
						swap_from_to(but)
						
						was_any = true
						break
					
					if m_pos.x <= pos.x and m_pos.x >= pos.x - gap_x:
						from.get_parent().remove_child(from)
						hbox.add_child(from)
						hbox.move_child(from, place)
						
						from = null
						was_any = true
						break
					
					place += 1
					
	holder0 = null


func but_down(sender: Button) -> void:
	holder0 = but_pressed(sender)
	from = sender
	holder0.modulate.a = 0.6


func but_pressed(sender: Button) -> Button:
	var clone: Button = clone_but(sender)
	clone.position = but_m_pos(clone)
	add_child(clone)
	
	return clone


func create_but(hcont: HBoxContainer, word: String) -> void:
	var but: Button = Button.new()
	but.text = '  ' + word + '  '
	but_add_themes(but)
	
	but.connect("button_down", func(): but_down(but))
	but.connect("button_up", func(): but_up(but))
	hcont.add_child(but)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var times = Singleton.time.split(':')
	$Bar/Time.text = times[1] + ':' + times[2]
	
	$ScrollContainer/VBoxContainer.remove_child($ScrollContainer/VBoxContainer/HBoxContainer)
	$ScrollContainer/VBoxContainer.remove_child($ScrollContainer/VBoxContainer/HBoxContainer2)
	
	if Singleton.did_task:
		return
	
	var i: int = 1
	var strs: Array = Array(strokes)
	strs.shuffle()
	var hbox_style: StyleBoxFlat = load("res://pc_images/vs/hbox_style.tres")
	
	for stroke in strs:
		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(608, 32)
		panel.add_theme_stylebox_override('panel', hbox_style)
		
		var hcont: HBoxContainer = HBoxContainer.new()
		hcont.custom_minimum_size = Vector2(608, 32)
		hcont.add_theme_constant_override('separation', 8)
		
		panel.add_child(hcont)
		$ScrollContainer/VBoxContainer.add_child(panel)

		var words: Array = Array(stroke.split('<w///>'))
		words.shuffle()
		for word in words:
			word = word.replace('\n', '').strip_edges()
			
			if word != '':
				if word == '<t///>':
					create_but(hcont, '        ')
				else:
					create_but(hcont, word)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var m_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if holder0 != null and m_pressed:
		holder0.position = but_m_pos(holder0)


func _on_start_but_button_down() -> void:
	if estimate_code():
		var task = Singleton.task
		var data = task.lang.data
		var text: String = FileAccess.open(task.lang.data_path, FileAccess.READ).get_as_text()

		var new_text: String = \
			'exp=' + str(data.exp + 1) + '\n' + \
			'slash_n=' + ('1' if data.slash_n else '0') + '\n' + \
			'tabs=' + ('1' if data.tabs else '0') + '\n' + \
			'did=' + ('' if data.did.size() == 0 else '|'.join(data.did) + '|') + str(task.code_name) + '\n' + \
			'comment=' + data.comment + '\n' + \
			'super_comment=' + data.super_comment
		var file = FileAccess.open(task.lang.data_path, FileAccess.WRITE)
		file.store_string(new_text)
		file.close()
			
		Singleton.money += task.price
		Singleton.did_task = true
		Singleton.add_time(ceil(task.code_name / 10))
		print(ceil(task.code_name / 10), ' time added')
		Singleton.go_to("res://scenes/chrome.tscn")
	else:
		#может чтото типа вы даун будет не знаю
		pass


func _on_start_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")


func _on_chrome_button_down() -> void:
	Singleton.go_to("res://scenes/chrome.tscn")
