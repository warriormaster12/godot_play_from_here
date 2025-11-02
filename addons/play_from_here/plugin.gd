@tool
extends EditorPlugin

var h_container: HBoxContainer = HBoxContainer.new()
var play_from_here_menu: MenuButton = MenuButton.new()
var selected_point_label: Label = Label.new()

var debugger_plugin: PlayFromHereDebuggerPlugin = null

var camera_transform: Transform3D = Transform3D.IDENTITY
var ray_origin: Vector3 = Vector3.ZERO
var ray_dest: Vector3 = Vector3.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var is_point_selection_requested: bool = false

var draw_gizmo: bool = false

var current_open_scene: Node = null

const DEFAULT_SELECTED_POINT_TEXT: String = 'Right click any point in the world to enable "Selected Point" option'

func _enter_tree() -> void:
	play_from_here_menu.text = "Play From..."
	play_from_here_menu.get_popup().add_item("Camera View", 0, KEY_C | KEY_MASK_SHIFT)
	play_from_here_menu.get_popup().add_item("Selected Point", 1, KEY_S | KEY_MASK_SHIFT)
	play_from_here_menu.get_popup().set_item_disabled(1, true)
	play_from_here_menu.get_popup().id_pressed.connect(_play_menu_item_pressed)
	
	selected_point_label.text = DEFAULT_SELECTED_POINT_TEXT
	
	h_container.add_child(play_from_here_menu)
	h_container.add_child(selected_point_label)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, h_container)
	
	debugger_plugin = preload("res://addons/play_from_here/play_from_here_debugger_plugin.gd").new()
	add_debugger_plugin(debugger_plugin)
	
	set_process(true)
	
	set_input_event_forwarding_always_enabled()

func _process(_delta: float) -> void:
	if !EditorInterface.is_playing_scene() && debugger_plugin.active:
		debugger_plugin.active = false
		debugger_plugin.use_selected_pos = false
	
	if current_open_scene == null:
		current_open_scene = EditorInterface.get_edited_scene_root()
	elif current_open_scene != EditorInterface.get_edited_scene_root():
		play_from_here_menu.get_popup().set_item_disabled(1, true)
		selected_point_label.text = DEFAULT_SELECTED_POINT_TEXT
		current_open_scene = EditorInterface.get_edited_scene_root()


func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event
		if !mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			return AFTER_GUI_INPUT_PASS
		
		if mouse_button.is_pressed():
			camera_transform = viewport_camera.global_transform
		elif mouse_button.is_released() && camera_transform == viewport_camera.global_transform:
			ray_origin = viewport_camera.project_ray_origin(mouse_pos)
			ray_dest = ray_origin + viewport_camera.project_ray_normal(mouse_pos) * 1000
			is_point_selection_requested = true
			
	elif event is InputEventMouseMotion:
		mouse_pos = EditorInterface.get_editor_viewport_3d().get_mouse_position()
	
	return AFTER_GUI_INPUT_PASS


func _physics_process(delta: float) -> void:
	if !is_point_selection_requested: 
		return

	var direct_space:PhysicsDirectSpaceState3D = get_tree().get_root().get_world_3d().direct_space_state
	var ray_params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_params.collide_with_bodies = true
	ray_params.from = ray_origin
	ray_params.to = ray_dest
	
	var result: Dictionary = direct_space.intersect_ray(ray_params)
	if result.has("position"):
		debugger_plugin.selected_point_position = result.position
		debugger_plugin.selected_point_position.y += 2.0
		play_from_here_menu.get_popup().set_item_disabled(1, false)
		is_point_selection_requested = false
		selected_point_label.text = "position: %s" %str(debugger_plugin.selected_point_position)

func _play_menu_item_pressed(idx: int) -> void:
	match idx:
		0:
			EditorInterface.play_current_scene()
			debugger_plugin.active = true
		1:
			EditorInterface.play_current_scene()
			debugger_plugin.active = true
			debugger_plugin.use_selected_pos = true


func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, h_container)
	remove_debugger_plugin(debugger_plugin)
