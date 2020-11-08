extends PanelContainer


const CUSTOM_LEVELS_PATH = "user://levels/"


onready var levels_list = $MarginContainer/HBoxContainer/CustomLevels


var selected_level: String


# Called when the node enters the scene tree for the first time.
func _ready():
	load_custom_levels()
	

func get_levelname_from_path(path: String) -> String:
	var regex = RegEx.new()
	regex.compile("(.+/)(.+)(.json)")
	var result = regex.search(path)
	
	return result.strings[2]
	


func load_custom_levels():
	levels_list.clear()
	
	var dir = Directory.new()
	var err = dir.open(CUSTOM_LEVELS_PATH)
	
	dir.list_dir_begin(true)
	var next = dir.get_next()
	
	while next != "":
		if next.ends_with(".json"):
			var level_name = get_levelname_from_path(CUSTOM_LEVELS_PATH + next)
			
			# load preview image
			var preview: Image = Image.new()
			var e = preview.load(CUSTOM_LEVELS_PATH + level_name + ".png")
			
			# create texture
			var texture = ImageTexture.new()
			texture.create_from_image(preview)
			
			# add level to list
			levels_list.add_item(level_name, texture)
		next = dir.get_next()
		
	dir.list_dir_end()


func delete_level(level: String):
	var dir = Directory.new()
	var error = dir.remove(level)
	print("Delete %s. Error: %d" %[level, error])
	load_custom_levels()


func export_level(level: String, destination: String):
	var dir = Directory.new()
	var error = dir.copy(level, destination)
	print("export %s to %s. Error: %d" % [level, destination, error])


func import_level(path: String) -> void:
	var dir = Directory.new()
	var file_name = path.substr(path.find_last("/"))
	
	var error = dir.copy(path, CUSTOM_LEVELS_PATH + file_name)
	print("export %s to %s. Error: %d" % [path, CUSTOM_LEVELS_PATH + filename, error])
	


func _on_CustomLevels_item_selected(index):
	$PopupPanel.popup_centered_minsize()
	$PopupPanel.rect_position = get_global_mouse_position()
	selected_level = CUSTOM_LEVELS_PATH + levels_list.get_item_text(index) + ".json"


func _on_Play_pressed() -> void:
	SceneLoader.goto_scene("res://scenes/Game.tscn", {"level_path": selected_level})


func _on_Edit_pressed() -> void:
	SceneLoader.goto_scene("res://scenes/level_editor/LevelEditor.tscn", {"level_path": selected_level})


func _on_Rename_pressed() -> void:
	$RenameFileDialog.popup_centered()
	$RenameFileDialog.dialog_text = "Rename %s to:" % get_levelname_from_path(selected_level)
	$RenameFileDialog/HBoxContainer2/LineEdit.text = get_levelname_from_path(selected_level)


func _on_Export_pressed() -> void:
	$ExportFileDialog.popup_centered()


func _on_Delete_pressed() -> void:
	$DeleteConfirmationDialog.popup_centered()


func _on_DeleteConfirmationDialog_confirmed() -> void:
	delete_level(selected_level)


func _on_ExportFileDialog_file_selected(destination: String) -> void:
	export_level(selected_level, destination)



func _on_NewLevel_pressed():
	var dir = Directory.new()
	var i = 1
	while dir.file_exists("user://levels/Untitled Level " + str(i) + ".json"):
		i += 1
	SceneLoader.goto_scene("res://scenes/level_editor/LevelEditor.tscn", {"level_path": "user://levels/Untitled Level " + str(i) + ".json"})


func _on_Import_pressed():
	$ImportFileDialog.popup_centered()
	

func _on_ImportFileDialog_file_selected(path):
	import_level(path)


func _on_Back_pressed():
	SceneLoader.goto_scene("res://scenes/TitleScreen.tscn")


func _on_PopupPanel_about_to_show():
	$AnimationPlayer.play("open_popup")



func _on_RenameFileDialog_confirmed():
	var dir = Directory.new()
	dir.rename(selected_level, CUSTOM_LEVELS_PATH + $RenameFileDialog/HBoxContainer2/LineEdit.text + ".json")
	load_custom_levels()