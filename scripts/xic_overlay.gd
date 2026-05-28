extends CanvasLayer

# ─── Exports ──────────────────────────────────────────────────────────────────
## How many compound entries appear per page of the XIC.
@export var entries_per_page: int = 3
## How long the "New Entry" popup stays visible (seconds).
@export var new_entry_popup_duration: float = 3.0

# ─── Node References ──────────────────────────────────────────────────────────
@onready var root_panel:       PanelContainer = $XICPanel
@onready var title_label:      Label          = $XICPanel/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var page_label:       Label          = $XICPanel/MarginContainer/VBoxContainer/HeaderRow/PageLabel
@onready var search_field:     LineEdit       = $XICPanel/MarginContainer/VBoxContainer/SearchField
@onready var scroll_container: ScrollContainer = $XICPanel/MarginContainer/VBoxContainer/ScrollContainer
@onready var entries_vbox:     VBoxContainer  = $XICPanel/MarginContainer/VBoxContainer/ScrollContainer/EntriesVBox
@onready var no_results_label: Label          = $XICPanel/MarginContainer/VBoxContainer/NoResultsLabel
@onready var hint_prev:        Label          = $XICPanel/MarginContainer/VBoxContainer/FooterRow/HintPrev
@onready var hint_next:        Label          = $XICPanel/MarginContainer/VBoxContainer/FooterRow/HintNext
@onready var new_entry_popup:  PanelContainer = $XICPanel/NewEntryPopup
@onready var new_entry_label:  Label          = $XICPanel/NewEntryPopup/NewEntryLabel

# ─── State ────────────────────────────────────────────────────────────────────
var _current_page: int  = 0
var _page_count:   int  = 4
var _search_query: String = ""
var _popup_timer:  SceneTreeTimer = null

# ─── Ready ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	root_panel.hide()
	new_entry_popup.hide()
	search_field.hide()   # Hidden until Search upgrade is unlocked (see unlock_feature_search)
	search_field.text_changed.connect(_on_search_changed)
	_apply_theme()
	# Listen for new compounds being added mid-game.
	XICDatabase.new_compound_unlocked.connect(_on_new_compound_unlocked)

# ─── Public API (called from Player script) ────────────────────────────────────

## Call this right after xic.pickup() to show the overlay.
func show_for_xic(page_count: int) -> void:
	_page_count = page_count
	_current_page = 0
	_search_query = ""
	search_field.text = ""
	root_panel.show()
	scroll_container.scroll_vertical = 0
	_refresh()

## Call this after xic.put_down() to hide the overlay.
func hide_xic() -> void:
	root_panel.hide()
	_search_query = ""
	search_field.text = ""

## Connected to XIC.page_changed signal — drives the displayed page.
func on_page_changed(page_index: int) -> void:
	_current_page = page_index
	scroll_container.scroll_vertical = 0
	_refresh()

## Unlockable feature: search bar.
func unlock_feature_search() -> void:
	XICDatabase.feature_search_unlocked = true
	search_field.show()

## Unlockable feature: chemical families.
func unlock_feature_families() -> void:
	XICDatabase.feature_families_unlocked = true
	_refresh()

## Unlockable feature: confidence ratings.
func unlock_feature_confidence() -> void:
	XICDatabase.feature_confidence_unlocked = true
	_refresh()

# ─── Private ──────────────────────────────────────────────────────────────────
func _refresh() -> void:
	_update_header()
	_update_hints()
	var compounds: Array = XICDatabase.search(_search_query)
	_populate_entries(_get_page_slice(compounds))

func _update_header() -> void:
	title_label.text = "Xenobiological Ingredients Compendium"
	var total: int = XICDatabase.get_unlocked_compounds().size()
	page_label.text = "Page %d / %d  (%d entries)" % [_current_page + 1, _page_count, total]

func _update_hints() -> void:
	hint_prev.text = "[← / xic_page_prev] Previous"
	hint_next.text = "Next [xic_page_next / →]"
	hint_prev.modulate.a = 0.4 if _current_page == 0 else 1.0
	hint_next.modulate.a = 0.4 if _current_page >= _page_count - 1 else 1.0

func _get_page_slice(compounds: Array) -> Array:
	var start: int = _current_page * entries_per_page
	return compounds.slice(start, start + entries_per_page)

func _populate_entries(compounds: Array) -> void:
	# Clear previous entries cleanly.
	for child in entries_vbox.get_children():
		child.queue_free()

	no_results_label.visible = compounds.is_empty()
	for entry in compounds:
		entries_vbox.add_child(_build_entry_row(entry))

func _build_entry_row(entry: XICDatabase.CompoundEntry) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_entry_stylebox(entry))

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	# Row 1: Name + Severity badge
	var top_row := HBoxContainer.new()
	var name_lbl := Label.new()
	name_lbl.text = entry.compound_name
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)

	var sev_lbl := Label.new()
	sev_lbl.text = XICDatabase.get_severity_label(entry.severity)
	sev_lbl.add_theme_font_size_override("font_size", 13)
	sev_lbl.add_theme_color_override("font_color", XICDatabase.get_severity_color(entry.severity))
	sev_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sev_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	top_row.add_child(name_lbl)
	top_row.add_child(sev_lbl)

	# Row 2: Family
	var family_lbl := Label.new()
	family_lbl.text = "Family: " + entry.family
	family_lbl.add_theme_font_size_override("font_size", 11)
	family_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))

	# Row 3: Effect description
	var effect_lbl := Label.new()
	effect_lbl.text = entry.effect
	effect_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_lbl.add_theme_font_size_override("font_size", 12)
	effect_lbl.add_theme_color_override("font_color", Color(0.9, 0.88, 0.82))

	vbox.add_child(top_row)
	vbox.add_child(family_lbl)
	vbox.add_child(effect_lbl)

	# Row 4 (conditional): Unverified warning
	if not entry.verified and XICDatabase.feature_confidence_unlocked:
		var warn_lbl := Label.new()
		warn_lbl.text = "⚠  Entry Unverified — treat with caution."
		warn_lbl.add_theme_font_size_override("font_size", 11)
		warn_lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.1))
		vbox.add_child(warn_lbl)
	elif not entry.verified:
		# Confidence feature not yet unlocked — show generic marker.
		var conf_lbl := Label.new()
		conf_lbl.text = "Confidence: ░░░░░"
		conf_lbl.add_theme_font_size_override("font_size", 11)
		conf_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vbox.add_child(conf_lbl)

	margin.add_child(vbox)
	panel.add_child(margin)
	return panel

func _make_entry_stylebox(entry: XICDatabase.CompoundEntry) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var base := Color(0.12, 0.11, 0.15)
	# Tint very subtly based on severity so lethal entries feel different.
	match entry.severity:
		XICDatabase.Severity.LETHAL:
			base = Color(0.18, 0.08, 0.08)
		XICDatabase.Severity.SEVERE:
			base = Color(0.16, 0.10, 0.07)
		XICDatabase.Severity.MILD:
			base = Color(0.12, 0.12, 0.08)
	sb.bg_color = base
	sb.border_width_left = 3
	sb.border_color = XICDatabase.get_severity_color(entry.severity)
	sb.corner_radius_top_left    = 4
	sb.corner_radius_top_right   = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	return sb

func _apply_theme() -> void:
	# Overall panel background — battered sci-fi tablet feel.
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.07, 0.07, 0.10, 0.95)
	bg.border_width_top    = 2
	bg.border_width_bottom = 2
	bg.border_width_left   = 2
	bg.border_width_right  = 2
	bg.border_color = Color(0.3, 0.55, 0.9, 0.8)
	bg.corner_radius_top_left    = 6
	bg.corner_radius_top_right   = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	root_panel.add_theme_stylebox_override("panel", bg)

	no_results_label.text = "No matching compounds found."
	no_results_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	no_results_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

# ─── New Compound Popup ────────────────────────────────────────────────────────
func _on_new_compound_unlocked(entry: XICDatabase.CompoundEntry) -> void:
	new_entry_label.text = "📋 New XIC Entry: %s" % entry.compound_name
	new_entry_popup.show()
	if _popup_timer != null:
		# Cancel any running timer so overlapping unlocks reset the duration.
		_popup_timer = null
	_popup_timer = get_tree().create_timer(new_entry_popup_duration)
	await _popup_timer.timeout
	new_entry_popup.hide()

# ─── Search ───────────────────────────────────────────────────────────────────
func _on_search_changed(query: String) -> void:
	_search_query = query
	_current_page = 0   # Reset to first page on new search.
	_refresh()
