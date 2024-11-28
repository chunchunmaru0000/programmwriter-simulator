extends Node2D

var endings: Dictionary = {
	1: [
		'Неким утром, а может и вечером(вы были не в сознании) пару людей в военной форме выломали вам дверь и вошли в важу жилплощадь.',
		'Увидев вас в критическом состоянии вас срочно доставили в ближайший госпиталь.',
		'В процессе вашего восстановления, хитрые врачи военкомата кончено же без вашего ведома провели вам медицинский осмотр.',
		'Оказалось, что ваша прежняя степень годности "В", была ошибкой. И с вашей «А1» вы благополучно отправились в армию после вашего восстановления.',
		'Единственное, что вы смогли сделать, это сказать, что вы высококвалифицированный технический специалист, а потому вы получили специальность «Пилот-оператор БПЛА»',
		'Может быть после армии вам еще выпадет шанс стать разработчиком программного обесечения',
	],
}

var history: Array
var ending: int
var id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ending = RandomNumberGenerator.new().randi_range(1, endings.size())
	_on_next_pressed()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_pressed() -> void:
	if id == endings[ending].size():
		get_tree().quit()
		return
	$ColorRect/RichTextLabel.text = endings[ending][id]
	id += 1
