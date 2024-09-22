extends Node2D


var fridge: Array


class Effect:
	var name: String
	var stat: String
	var value
	
	func _init(name: String, stat: String, value) -> void:
		self.name = name
		self.stat = stat
		self.value = value
	
		
class Product:
	var name: String
	var frame: int
	var price: float
	var hunger: int
	var thirst: int
	var have_discount: bool
	var discount: float
	var expiration_days: int
	var expiration_hours: int
	var eatings_max: int
	var eatings: int
	var effects: Array[Effect]
	
	func _init(name: String, frame: int, price: float, hunger: int, thirst: int, eatings_max: int, expiration_days: int, effects: Array=[Effect]) -> void:
		var rnd = RandomNumberGenerator.new()
		self.name = name
		self.frame = frame
		self.hunger = hunger
		self.thirst = thirst
		self.effects = effects
		
		self.have_discount = rnd.randi_range(0, 100) < 5
		self.discount = rnd.randi_range(-3, 10) * 5
		if self.have_discount:
			self.price = price / 100 * (100 - discount)
		else:
			self.price = price
		if self.discount <= 0:
			self.discount = rnd.randi_range(5, 10) * 5
		
		self.expiration_days = expiration_days
		self.expiration_hours = 0
		self.eatings_max = eatings_max
		self.eatings = eatings_max
		
		

func eat_owned_product(but, product) -> void:
	var at = 0
	for i in fridge.size():
		if product == fridge[i]:
			at = i
	
	if product.eatings == 1:
		Singleton.remove_fridge_at(at)
		$ProductsScroll/FridgeBox.remove_child(but.get_parent().get_parent().get_parent())
	else:
		product.eatings -= 1
		Singleton.set_fridge_at(at, product)
		but.text = "Съесть " + str(product.eatings) + "/" + str(product.eatings_max)
		
		
func toss_owned_product(but, product) -> void:
	var at = 0
	for i in fridge.size():
		if product == fridge[i]:
			at = i
	Singleton.remove_fridge_at(at)
	$ProductsScroll/FridgeBox.remove_child(but.get_parent().get_parent().get_parent())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fridge = Singleton.fridge
	var but_height = 24
	var anim_wide = 112
	var anim_height = anim_wide
	var cont_wide = 632 - 8
	var info_wide = cont_wide - anim_wide
	
	for product in fridge:
		var garbage_but = Button.new()
		garbage_but.text = "Выбросить"
		garbage_but.custom_minimum_size.x = anim_height
		garbage_but.custom_minimum_size.y = but_height
		var da = func():
			toss_owned_product(garbage_but, product)
		garbage_but.connect("button_down", da)
		
		var eat_but = Button.new()
		eat_but.text = "Съесть " + str(product.eatings) + "/" + str(product.eatings_max)
		eat_but.custom_minimum_size.x = cont_wide - anim_height
		eat_but.custom_minimum_size.y = but_height
		da = func():
			eat_owned_product(eat_but, product)
		eat_but.connect("button_down", da)
		
		var butsBox = HBoxContainer.new()
		butsBox.custom_minimum_size.x = cont_wide
		butsBox.custom_minimum_size.y = but_height + but_height
		butsBox.add_child(eat_but)
		butsBox.add_child(garbage_but)
		
		var expr = Label.new()
		expr.text = "Срок годности: " + str(product.expiration_days) + " дней " + str(product.expiration_hours) + " часов"
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
		anim.texture = preload("res://images/products/products_anim.tres").get_frame_texture("default", product.frame)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = anim_wide
		anim.custom_minimum_size.y = anim_height
		
		var info = Label.new()
		info.custom_minimum_size.y = anim_height
		var effects_strs: Array = []
		for effect in product.effects:
			effects_strs.append(" - " + effect.name + ": " + effect.stat + " " + str(effect.value))
		info.text = "\n".join([
			product.name,
			"Сытость: " + str(product.hunger),
			"Жажда: " + str(product.thirst),
			#"Эффекты: ",
			#"\n".join(effects_strs)	
		] + (["Эффекты: ",
			"\n".join(effects_strs)] if product.effects.size() > 0 else []))
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
		
		$ProductsScroll/FridgeBox.add_child(mainBox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	Singleton.save_progress()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
