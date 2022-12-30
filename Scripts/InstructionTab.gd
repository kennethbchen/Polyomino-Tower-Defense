extends Tabs

var parent: TabContainer

onready var next_button = $NavigationPanel/Navigation/NextButton

onready var back_button = $NavigationPanel/Navigation/BackButton

func _ready():
	
	if get_parent() is TabContainer:
		parent = get_parent() as TabContainer
		
	if get_index() == 0:
		back_button.visible = false
	
	if get_index() == parent.get_child_count() - 1:
		next_button.visible = false


func _next():
	parent.current_tab = min(parent.get_tab_count() - 1, parent.current_tab + 1)

func _back():
	parent.current_tab = max(0, parent.current_tab - 1)
