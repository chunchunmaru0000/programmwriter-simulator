extends Control


func _on_newgame_button_down() -> void:
	Singleton.clear()
	
	var save_file : String = Singleton.save_file
	var new_save_file : String = save_file
	var file = FileAccess.open("res://" + save_file, FileAccess.READ)
	
	if file.get_as_text() != "":
		var count = 0
		while file and file.get_as_text() != "":
			file = FileAccess.open(
				"res://" + str(count) + save_file,
			 	FileAccess.READ
				)
			new_save_file = str(count) + save_file
			count += 1
		
		if new_save_file != save_file:
			Singleton.set_save_file(new_save_file)
	
	Singleton.go_to("res://scenes/game.tscn")
	

func _on_load_pressed() -> void:
	$"../FileDialog".popup()
	

func _on_file_dialog_file_selected(path: String) -> void:
	Singleton.load_progress(path)
	if Singleton.hp < 1:
		get_tree().change_scene_to_file("res://scenes/ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()
	
	
func _ready() -> void:
	#Singleton.proj = '/'.join(OS.get_executable_path().split('/').slice(0, -1)) + '/'
	Singleton.proj = ProjectSettings.globalize_path('res://')
	print(Singleton.proj)
	
