extends CanvasLayer
class_name Book

## All pages in reading order. Index 0 is the first right-hand page,
## index 1 the next left-hand page, and so on (odd/even = left/right).
@export var pages: Array[Texture2D] = []

@export var flip_duration: float = 0.6

## Assign page_curl.gdshader here in the Inspector.
@export var page_curl_shader: Shader

@onready var l_page: TextureRect = $LPage
@onready var r_page: TextureRect = $RPage
@onready var turn_front: TextureRect = $TurnPageFront
@onready var turn_back: TextureRect = $TurnPageBack

var current_index: int = 0  # index of the page currently shown on RPage
var is_flipping: bool = false

var _front_mat: ShaderMaterial
var _back_mat: ShaderMaterial

func _ready() -> void:
	_front_mat = ShaderMaterial.new()
	_front_mat.shader = page_curl_shader
	turn_front.material = _front_mat
	turn_front.z_index = 1

	_back_mat = ShaderMaterial.new()
	_back_mat.shader = page_curl_shader
	turn_back.material = _back_mat
	turn_back.z_index = 1

	turn_front.visible = false
	turn_back.visible = false
	refresh()

func _unhandled_input(event: InputEvent) -> void:
	if is_flipping:
		return
	if event.is_action_pressed("ui_right"):
		turn_next()
	elif event.is_action_pressed("ui_left"):
		turn_previous()
	elif event.is_action_pressed("ui_cancel"):
		hide()

## Updates the static left/right pages to match current_index.
func refresh() -> void:
	set_page_texture(l_page, current_index - 1)
	set_page_texture(r_page, current_index)

func set_page_texture(node: TextureRect, index: int) -> void:
	if index < 0 or index >= pages.size():
		node.visible = false
		return
	node.visible = true
	node.texture = pages[index]

func turn_next() -> void:
	if current_index >= pages.size() - 1:
		return
	is_flipping = true
	var next_index := current_index + 1

	# Show the upcoming right page underneath right away, so it's visible
	# through the curl as the current page turns away from it.
	set_page_texture(r_page, next_index)

	turn_front.position = r_page.position
	turn_front.size = r_page.size
	turn_front.texture = pages[current_index]
	turn_front.visible = true
	_front_mat.set_shader_parameter("pivot_right", false)
	_front_mat.set_shader_parameter("page_width", turn_front.size.x)
	_front_mat.set_shader_parameter("fold", 0.0)

	var tween := create_tween()
	# Fold the page down flat against its own spine (right edge of the spread)...
	tween.tween_method(func(v): _front_mat.set_shader_parameter("fold", v), 0.0, 1.0, flip_duration / 2.0)
	# ...then re-anchor it on the left slot and unfold it back out from that spine.
	tween.tween_callback(func() -> void:
		turn_front.position = l_page.position
		turn_front.size = l_page.size
		_front_mat.set_shader_parameter("pivot_right", true)
		_front_mat.set_shader_parameter("page_width", turn_front.size.x)
	)
	tween.tween_method(func(v): _front_mat.set_shader_parameter("fold", v), 1.0, 0.0, flip_duration / 2.0)
	await tween.finished

	current_index = next_index
	turn_front.visible = false
	refresh()
	is_flipping = false

func turn_previous() -> void:
	if current_index <= 0:
		return
	is_flipping = true
	var prev_index := current_index - 1

	# Show the upcoming left page underneath right away, same idea in reverse.
	set_page_texture(l_page, prev_index - 1)

	turn_back.position = l_page.position
	turn_back.size = l_page.size
	turn_back.texture = pages[prev_index]
	turn_back.visible = true
	_back_mat.set_shader_parameter("pivot_right", true)
	_back_mat.set_shader_parameter("page_width", turn_back.size.x)
	_back_mat.set_shader_parameter("fold", 0.0)

	var tween := create_tween()
	tween.tween_method(func(v): _back_mat.set_shader_parameter("fold", v), 0.0, 1.0, flip_duration / 2.0)
	tween.tween_callback(func() -> void:
		turn_back.position = r_page.position
		turn_back.size = r_page.size
		_back_mat.set_shader_parameter("pivot_right", false)
		_back_mat.set_shader_parameter("page_width", turn_back.size.x)
	)
	tween.tween_method(func(v): _back_mat.set_shader_parameter("fold", v), 1.0, 0.0, flip_duration / 2.0)
	await tween.finished

	current_index = prev_index
	turn_back.visible = false
	refresh()
	is_flipping = false
