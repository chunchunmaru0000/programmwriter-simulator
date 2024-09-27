extends Node2D

class Lang:
	var name: String
	var img: String
	var exp: int
	
	func _init(name: String, img: String) -> void:
		self.name = name
		self.img = img
		self.exp = 0

var langs: Array = [
	Lang.new("C#", "res://images/work/Logo-csharp.png"),
	Lang.new("Python", "res://images/work/Python-logo-notext.svg.png"),
	Lang.new("JavaScript", "res://images/work/Unofficial_JavaScript_logo_2.svg.png")
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var but_height = 24
	var anim_wide = 112
	var anim_height = anim_wide
	var cont_wide = 632 - 8
	var info_wide = cont_wide - anim_wide
	
	for lang in langs:
		var garbage_but = Button.new()
		garbage_but.text = "Учить"
		garbage_but.custom_minimum_size.x = anim_height
		garbage_but.custom_minimum_size.y = but_height
		var da = func():
			pass
			# toss_owned_product(garbage_but, product)
		garbage_but.connect("button_down", da)
		
		var eat_but = Button.new()
		eat_but.text = "РАБотать"
		eat_but.custom_minimum_size.x = cont_wide - anim_height
		eat_but.custom_minimum_size.y = but_height
		da = func():
			pass
			# eat_owned_product(eat_but, product)
		eat_but.connect("button_down", da)
		
		var butsBox = HBoxContainer.new()
		butsBox.custom_minimum_size.x = cont_wide
		butsBox.custom_minimum_size.y = but_height + but_height
		butsBox.add_child(eat_but)
		butsBox.add_child(garbage_but)
		
		var expr = Label.new()
		expr.text = "Ваш опыт: " + str(lang.exp) # + " дней " + str(product.expiration_hours) + " часов"
		var expr_rect = ColorRect.new()
		expr_rect.custom_minimum_size = Vector2(cont_wide, but_height)
		expr_rect.color = Color(0.2, 0.2, 0.5, 0.5)
		expr_rect.add_child(expr)
		
		var text_butsBox = VBoxContainer.new()
		text_butsBox.custom_minimum_size.x = cont_wide
		text_butsBox.custom_minimum_size.y = but_height + but_height
		text_butsBox.add_child(expr_rect)
		text_butsBox.add_child(butsBox)
		
		
		var anim = TextureRect.new()
		anim.texture = load(lang.img)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = anim_wide
		anim.custom_minimum_size.y = anim_height
		
		var info = Label.new()
		info.custom_minimum_size.y = anim_height
		var effects_strs: Array = []
		info.text = "ЫЫЫ"
		var info_rect = ColorRect.new()
		info_rect.custom_minimum_size.x = info_wide - 8
		info_rect.custom_minimum_size.y = info.get_combined_minimum_size().y
		info_rect.color = Color(0.2, 0.2, 0.5, 0.5)
		info_rect.add_child(info)
		
		var infoCont = ScrollContainer.new()
		infoCont.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		infoCont.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		infoCont.custom_minimum_size.x = info_wide
		infoCont.custom_minimum_size.y = anim_height
		infoCont.add_child(info_rect)
		
		var anim_infoBox = HBoxContainer.new()
		anim_infoBox.custom_minimum_size.x = cont_wide
		anim_infoBox.custom_minimum_size.y = anim_wide
		anim_infoBox.add_child(anim)
		anim_infoBox.add_child(infoCont)
		
		var mainBox = VBoxContainer.new()
		mainBox.custom_minimum_size.x = cont_wide
		mainBox.custom_minimum_size.y = anim_height + but_height + but_height
		mainBox.add_child(anim_infoBox)
		mainBox.add_child(text_butsBox)
		
		$LangsScroll/LangBox.add_child(mainBox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	Singleton.go_to("res://scenes/game.tscn")
