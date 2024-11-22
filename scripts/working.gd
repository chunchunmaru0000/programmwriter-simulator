extends Node2D


var rnd = RandomNumberGenerator.new()

var dragging: bool = false
var from: Button = null
var to: Button = null
var holder0: Button = null:
	set(value):
		if holder0:
			remove_child(holder0)
			holder0.queue_free()
		holder0 = value

var text: String = '' if Singleton.did_task else FileAccess.open(Singleton.task_path, FileAccess.READ).get_as_text().replace('\r', '').split('\n<data///>\n')[-1]
var text_bez_n = text.replace('<n///>', '')
var strokes: PackedStringArray = text_bez_n.split('\n')
var all_words_ordered: Array
var tab_text: String = '        '
var final_tab_text: String = '  ' + tab_text + '  '

var r_press: bool = false
var r_begin: Vector2
var area_but: Button
# подсказка как управлять знак наверно восклицательный
# развернуть задание даже не знаю

class ButConcPlaceText:
	var hcont: HBoxContainer
	var place: Vector2
	var text: String
	var but: Button
	
	func _init(hcont: HBoxContainer, place: Vector2, text: String, but: Button) -> void:
		self.but = but
		self.hcont = hcont
		self.place = place
		self.text = text
	

func get_words() -> Array:
	if Singleton.slash_n and Singleton.tabs:	
		return all_words_ordered.duplicate(true)
	elif Singleton.slash_n and not Singleton.tabs:
		return all_words_ordered.duplicate(true). \
		filter(func(word: String): return not word.strip_edges() in ['<t///>', ''])
	else:
		return all_words_ordered.duplicate(true). \
		filter(func(word: String): return not word.strip_edges() in ['<t///>', '<n///>', ''])
	
	
func get_buts() -> Array:
	var buts: Array
	
	if Singleton.slash_n and Singleton.tabs:
		var j: int = -1
		for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
			var hcont: HBoxContainer = panel.get_child(0)
			j += 1
			if hcont.get_child_count():
				var i: int = -1
				for but: Button in hcont.get_children():
					i += 1
					var stripped_but: String = but.text.strip_edges()
					var but_text: String = stripped_but
					if stripped_but == '' and but.text.length() == tab_text.length() + 4:
						but_text = '<t///>'
					
					buts.append(ButConcPlaceText.new(hcont, Vector2(i, j), but_text, but))
				buts.append(ButConcPlaceText.new(hcont, Vector2(i + 1, j), '<n///>', null))
		if buts:# buts.remove_at(buts.size() - 1)
			while buts[-1].text == '<n///>':
				buts.remove_at(buts.size() - 1)
	elif Singleton.slash_n and not Singleton.tabs:
		var j: int = -1
		for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
			var hcont: HBoxContainer = panel.get_child(0)
			j += 1
			if hcont.get_child_count():
				var i: int = -1
				for but: Button in hcont.get_children():
					i += 1
					var stripped_but: String = but.text.strip_edges()
					if not(stripped_but == '' and but.text.length() == tab_text.length() + 4):
						buts.append(ButConcPlaceText.new(hcont, Vector2(i, j), but.text.strip_edges(), but))
				buts.append(ButConcPlaceText.new(hcont, Vector2(i + 1, j), '<n///>', null))
		if buts: #buts.remove_at(buts.size() - 1)
			while buts[-1].text == '<n///>':
				buts.remove_at(buts.size() - 1)
	else:
		var j: int = -1
		for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
			var hcont: HBoxContainer = panel.get_child(0)
			j += 1
			if hcont.get_child_count():
				var i: int = -1
				for but: Button in hcont.get_children():
					i += 1
					if but.text != final_tab_text and but.text != '<n///>':
						buts.append(ButConcPlaceText.new(hcont, Vector2(i, j), but.text.strip_edges().replace('\n', ''), but))
						#buts.append(but.text.strip_edges().replace('\n', ''))
	return buts


func estimate_code() -> bool:
	if Singleton.did_task:
		return false
		
	var words: Array = get_words()
	var buts: Array = get_buts()
	
	if words.size() != buts.size():
		return false
		
	var trues: int = 0
	for i in words.size():
		if words[i] == buts[i].text:
			trues += 1
	
	return trues == words.size()


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
		
		if from_place > to_place and from_parrent.position == to_parrent.position:
			to_parrent.move_child(from, to_place)
			from_parrent.move_child(to, from_place)
		else:
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
	dragging = false
	holder0 = null
	
	var was_any: bool = false
	var m_pos: Vector2 = get_global_mouse_position()
	var gap_y2: int = $ScrollContainer/VBoxContainer.get_theme_constant('separation') / 2
	var more_than_last_but_width: bool = false
	
	if m_pos.y > $ScrollContainer/VBoxContainer.size.y + $ScrollContainer/VBoxContainer.global_position.y:
		var hbox_style: StyleBoxFlat = load("res://pc_images/vs/hbox_style.tres")
		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(608, 32)
		panel.add_theme_stylebox_override('panel', hbox_style)
		
		var hcont: HBoxContainer = HBoxContainer.new()
		hcont.custom_minimum_size = Vector2(608, 32)
		hcont.add_theme_constant_override('separation', 8)
		
		panel.add_child(hcont)
		$ScrollContainer/VBoxContainer.add_child(panel)
		
		from.get_parent().remove_child(from)
		hcont.add_child(from)
	else:
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
							to_place.call()
							hbox.move_child(from, place)
							
							from = null
							was_any = true
							break
						
						place += 1


func but_down(sender: Button) -> void:
	dragging = true
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
	
	var vbar: VScrollBar = $TZ/TZText.get_v_scroll_bar()
	vbar.custom_minimum_size.x = 16
	vbar.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
	vbar.add_theme_stylebox_override('scroll', preload("res://pc_images/chrome/money/scroll_style.tres"))
	
	vbar.add_theme_stylebox_override('grabber', preload("res://pc_images/chrome/money/grabber_style.tres"))
	vbar.add_theme_stylebox_override('grabber_highlight', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
	vbar.add_theme_stylebox_override('grabber_pressed', preload("res://pc_images/chrome/money/grabber_style_act.tres"))
	
	
	if Singleton.did_task:
		return
	
	$TZ/TZText.text = Singleton.task.text
	
	var hbox_style: StyleBoxFlat = load("res://pc_images/vs/hbox_style.tres")
	var strs: Array = text.split('\n')#Array(strokes)
	var new_order: Array = []
	var lines = text.split('\n')
	for stroke in strs:
		var words: Array = Array(stroke.replace('<n///>', '').split('<w///>'))
		#for i in words.size():
			#words[i] = words[i].replace('<t///>', final_tab_text)
		all_words_ordered.append_array(words.filter(func(s: String): return s.strip_edges() != '').duplicate(true))
		if stroke.contains('<n///>'):
			all_words_ordered.append('<n///>')
			
		words.shuffle()
		new_order.append(words)
	while all_words_ordered[-1] == '<n///>':
		all_words_ordered.remove_at(all_words_ordered.size() - 1)
	#print(all_words_ordered)
	new_order.shuffle()

	for stroke in new_order:
		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(608, 32)
		panel.add_theme_stylebox_override('panel', hbox_style)
		
		var hcont: HBoxContainer = HBoxContainer.new()
		hcont.custom_minimum_size = Vector2(608, 32)
		hcont.add_theme_constant_override('separation', 8)
		
		panel.add_child(hcont)
		$ScrollContainer/VBoxContainer.add_child(panel)
		
		for word in stroke:
			word = word.replace('\n', '').strip_edges()
			
			if word != '':
				if word == '<t///>':
					create_but(hcont, tab_text)
				else:
					create_but(hcont, word)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var m_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var r_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	if holder0 != null and m_pressed:
		holder0.position = but_m_pos(holder0)
		
	if not dragging and m_pressed and holder0:
		holder0 = null
		
	if r_pressed:
		to_selected_area()
	else:
		r_press = false
		if area_but:
			get_selected_area_buts()
			remove_child(area_but)


func to_selected_area() -> void:
	var r_mouse = get_global_mouse_position()
	if not r_press:
		r_press = true
		r_begin = r_mouse
		
		area_but = Button.new()
		area_but.add_theme_stylebox_override('hover', load("res://pc_images/vs/area_style.tres"))
		area_but.add_theme_stylebox_override('hover_pressed', load("res://pc_images/vs/area_style.tres"))
		area_but.add_theme_stylebox_override('pressed', load("res://pc_images/vs/area_style.tres"))
		area_but.add_theme_stylebox_override('focus', load("res://pc_images/vs/area_style.tres"))
		area_but.add_theme_stylebox_override('normal', load("res://pc_images/vs/area_style.tres"))
		area_but.position = r_begin
		area_but.size = Vector2.ZERO
		
		add_child(area_but)
	else:
		if r_mouse.x < r_begin.x and r_mouse.y < r_begin.y:
			area_but.position = r_mouse
			area_but.size = r_begin - r_mouse
		elif r_mouse.x < r_begin.x:
			area_but.position = Vector2(r_mouse.x, r_begin.y)
			area_but.size = Vector2(r_begin.x - r_mouse.x, r_mouse.y - r_begin.y)
		elif r_mouse.y < r_begin.y:
			area_but.position = Vector2(r_begin.x, r_mouse.y)
			area_but.size = Vector2(r_mouse.x - r_begin.x, r_begin.y - r_mouse.y)
		else:
			area_but.position = r_begin
			area_but.size = r_mouse - r_begin
	

func get_selected_area_buts() -> Array:
	var buts: Array
	
	#for panel: PanelContainer in $ScrollContainer/VBoxContainer.get_children():
		#if panel.global_position.y + panel.size.y <= 
	return []


func c_str(c: String, s: String) -> String:
	return '[color=#' + c + ']' + s + '[/color]'


func _on_start_but_pressed() -> void:
	if Singleton.did_task: return
		
	if estimate_code():
		var task = Singleton.task
		var data = task.lang.data
		var text: String = FileAccess.open(task.lang.data_path, FileAccess.READ).get_as_text()
		
		var didexp = Singleton.didexps[task.lang.name]
		didexp.exp += 1
		didexp.did = str(task.code_name) if didexp.did == '' else didexp.did + '|' + str(task.code_name)

		Singleton.money += task.price
		Singleton.did_task = true
		Singleton.add_time(ceil(task.code_name / 10.))
		
		var chasov: String = str(ceil(task.code_name / 10.)) + ' '
		var chas = int(chasov[chasov.length() - 2])
		chas = 'час' if chas == 1 else 'часа' if chas > 1 and chas < 5 else 'часов'
		
		$WinnerPanel.position.x = -648 * 2
		$WinnerPanel/Rewards.text = \
			'Стаж ' + task.lang.name + ': ' + str(didexp.exp - 1) + c_str('ffb300', ' -> ') + c_str('66ff66', str(didexp.exp)) + '\n' + \
			'Капитал: ' + str(Singleton.money - task.price) + c_str('ffb300', ' -> ') + c_str('66ff66', str(Singleton.money)) + '\n' + \
			'Времени прошло: ' + chasov + chas
	else:
		#может чтото типа вы даун будет не знаю
		do_buts_coloring()


func _on_start_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")


func _on_chrome_button_down() -> void:
	Singleton.go_to("res://scenes/chrome.tscn")


func _on_close_scene_pressed() -> void:
	Singleton.go_to("res://scenes/chrome.tscn")


func _on_lamp_pressed() -> void:
	var words: Array = get_words()
	var buts: Array = get_buts()
	var trues: int = 0

	for i in words.size():
		if words[i] == buts[i].text:
			trues += 1
		else:
			break
	
	if trues != buts.size():
		var wrong_but_pos: Vector2
		var needed_but: Button
		
		if Singleton.slash_n:
			if words[trues] == '<n///>' and buts[trues].text != '<n///>':
				for i in range(trues, buts.size()):
					if words[trues + 1] == buts[i].text:
						needed_but = buts[i].but
						
				if buts[trues].place.y + 1 < $ScrollContainer/VBoxContainer.get_child_count():
					wrong_but_pos = $ScrollContainer/VBoxContainer.get_child(buts[trues].place.y + 1).global_position
				else:
					# я надеюсь этот  + 1 не будет иметь баг
					wrong_but_pos = Vector2($ScrollContainer.global_position.x, 
					$ScrollContainer/VBoxContainer.size.y + $ScrollContainer/VBoxContainer.get_child(0).size.y +
					$ScrollContainer/VBoxContainer.get_theme_constant("separation"))
					
			elif words[trues] != '<n///>' and buts[trues].text == '<n///>':
				var bomj: Button = buts[trues - 1].but
				wrong_but_pos = Vector2(bomj.global_position.x + bomj.size.x + (buts[trues - 1].hcont as HBoxContainer).get_theme_constant('separation'), bomj.global_position.y)
			else:
				wrong_but_pos = buts[trues].but.global_position
		else:
			wrong_but_pos = buts[trues].but.global_position
			
		if needed_but == null:
			for i in range(trues, buts.size()):
				if words[trues] == buts[i].text:
					needed_but = buts[i].but
					break
	
		
		holder0 = but_pressed(needed_but)
		holder0.position = needed_but.global_position
		holder0.modulate.a = 0.6
		
		var steps = 100.
		var time = 2.
		
		for step in steps:
			if holder0 and not dragging:
				holder0.position = lerp(holder0.position, wrong_but_pos, step / steps) 
				#print('from: ', holder0.position, '; to: ', wrong_but_pos, '; step ', step)
				await get_tree().create_timer(time / steps).timeout
			else:
				break
		if not dragging:
			holder0 = null
	else:
		do_buts_coloring()
	
	
func do_buts_coloring() -> void:
	var words: Array = get_words()
	var buts: Array = get_buts()
	var trues: int = 0
	var border_width_max = 4
	var border_width = 0
	
	for i in words.size():
		if words[i] == buts[i].text:
			trues += 1
		else:
			break
	
	var red: StyleBoxFlat
	var green: StyleBoxFlat
	
	var steps = 10.
	var time = 0.25
	
	for step in steps * 2:
		if step > steps:
			border_width = border_width_max / steps * (steps * 2 - step)
		else:
			border_width = border_width_max / steps * step
	
		if buts:
			red = (buts[0].but as Button).get_theme_stylebox('normal').duplicate(true)
			red.border_width_left = border_width
			red.border_width_bottom = border_width
			red.border_width_top = border_width
			red.border_width_right = border_width
			red.border_color = Color('#ff6666')
			
			green = (buts[0].but as Button).get_theme_stylebox('normal').duplicate(true)
			green.border_width_left = border_width
			green.border_width_bottom = border_width
			green.border_width_top = border_width
			green.border_width_right = border_width
			green.border_color = Color('#66ff66')
			
		for i in trues:
			if buts[i].text != '<n///>':
				(buts[i].but as Button).add_theme_stylebox_override('normal', green)
		for i in range(trues, buts.size()):
			if buts[i].text != '<n///>':
				(buts[i].but as Button).add_theme_stylebox_override('normal', red)
				
		await get_tree().create_timer(time / steps).timeout
	

func _on_tz_but_pressed() -> void:
	var time: float = 0.1
	var steps = 24
	var traectory = $TZ/ColorRect.size.y
	
	for step in steps:
		$TZ.position.y = -traectory + (float(step) / steps) * traectory
		await get_tree().create_timer(time / steps).timeout
	$TZ.position.y = 0


func _on_tz_up_pressed() -> void:
	var time: float = 0.1
	var steps = 24
	var traectory = $TZ/ColorRect.size.y
	
	for step in steps:
		$TZ.position.y = -traectory + (float(steps - step) / steps) * traectory
		await get_tree().create_timer(time / steps).timeout
	$TZ.position.y = -traectory
