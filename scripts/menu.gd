extends Control


func _on_newgame_button_down() -> void:
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
		
	Singleton.save_progress()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	

func _on_load_pressed() -> void:
	$"../FileDialog".popup()
	

func _on_file_dialog_file_selected(path: String) -> void:
	Singleton.load_progress($"../FileDialog".current_file)
	
	
	var file = FileAccess.open($"../FileDialog".current_file, FileAccess.READ)
	var lines = file.get_as_text().split('\n')
	
	Singleton.set_hp(lines[0].split(' ')[1])
	Singleton.set_money(lines[1].split(' ')[1])
	Singleton.set_hunger(lines[2].split(' ')[1])
	Singleton.set_thirst(lines[3].split(' ')[1])
	Singleton.set_sleep(lines[4].split(' ')[1])
	Singleton.set_time(lines[5].split(' ')[1])
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()
