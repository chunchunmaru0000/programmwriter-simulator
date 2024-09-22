extends Node2D


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
	
	func _init(name: String, frame: int, price: float, hunger: int, thirst: int, eatings_max: int, expiration_days: int, effects: Array[Effect]=[]) -> void:
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

var year = 365
var all_products = [
	Product.new("Гречка",        0,   36,   20,   0,    8,    year),
	Product.new("Хлеб чёрный",   1,   52,   6,    -5,   4,    4),
	Product.new("Хлеб белый",    2,   32,   5,    -5,   4,    4),
	Product.new("Чай зеленый",   3,   50,   0,    10,   10,   year, [Effect.new("Бодрость", "Сон", -1)]),
	Product.new("Чай чёрный",    4,   49,   0,    10,   10,   year, [Effect.new("Бодрость", "Сон", -1)]),
	Product.new("Колбаса",       5,   200,  30,   0,    7,    7),
	Product.new("Овсянка в пакетиках",
								 6,   173,  15,   0,    5,    year),
	Product.new("Квас",          7,   65,   0,    8,    10,   year),
	Product.new("Пиво",          8,   45,   0,    2,    2,    year, [Effect.new("Сонность", "Сон", 1), Effect.new("Вредность", "Здоровье", -1)]),
]

var rnd = RandomNumberGenerator.new()
var products = []


func remove_owned_product(but: Button, product: Product) -> void:
	var money = Singleton.money
	if money - product.price < 0:
		pass
	else:
		Singleton.set_money(money - product.price)
		Singleton.append_fridge(product)
		
		var at = 0
		for i in products.size():
			if product == products[i]:
				at = i
		
		products.remove_at(at)
		$ProductsScroll/ProductGrid.remove_child(but.get_parent())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Singleton.add_time(1)
	
	for i in rnd.randi_range(20, 100):
		products.append(all_products[rnd.randi_range(0, all_products.size() - 1)])
	products.sort_custom(func (a, b): return a.price > b.price)
	
	var column_wide = 292 # 112
	
	for product in products:
		var anim = TextureRect.new()
		anim.texture = preload("res://images/products/products_anim.tres").get_frame_texture("default", product.frame)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = column_wide
		anim.custom_minimum_size.y = column_wide - 24 - 24
		
		
		var label = Label.new()
		if product.have_discount:
			label.text = product.name + " СКИДКА " + str(product.discount) + "%"
		else:
			label.text = product.name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(column_wide, 24)
		color_rect.color = Color(0.2, 0.2, 0.5, 0.5)
		color_rect.add_child(label)
		
		
		var but = Button.new()
		but.text = str(product.price) + "руб."
		but.custom_minimum_size.x = column_wide
		but.custom_minimum_size.y = 24
		
		var da = func():
			remove_owned_product(but, product)
		but.connect("button_down", da)

		
		var cont = VBoxContainer.new()
		cont.add_child(anim)
		cont.add_child(color_rect)
		cont.add_child(but)
		cont.custom_minimum_size.x = column_wide
		cont.custom_minimum_size.y = column_wide
		
		$ProductsScroll/ProductGrid.add_child(cont)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	Singleton.save_progress()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
