# XICDatabase.gd
# Autoload singleton — stores and manages all compound entries.
# Add via: Project > Project Settings > Autoload > path: res://scripts/XICDatabase.gd > name: XICDatabase

extends Node

# ─── Severity Tiers ───────────────────────────────────────────────────────────
enum Severity { SAFE, MILD, SEVERE, LETHAL }

const SEVERITY_LABELS: Dictionary = {
	Severity.SAFE:   "Safe ✅",
	Severity.MILD:   "Effect ⚠️",
	Severity.SEVERE: "Severe ⚠️⚠️",
	Severity.LETHAL: "Lethal ☠️",
}

# Colours used by the UI to tint severity badges.
const SEVERITY_COLORS: Dictionary = {
	Severity.SAFE:   Color(0.3, 0.9, 0.4),
	Severity.MILD:   Color(1.0, 0.8, 0.2),
	Severity.SEVERE: Color(1.0, 0.4, 0.1),
	Severity.LETHAL: Color(0.9, 0.1, 0.1),
}

# ─── Compound Entry ───────────────────────────────────────────────────────────
class CompoundEntry:
	var id: String           # Unique snake_case key  e.g. "bioluminite_7"
	var compound_name: String  # Display name
	var family: String       # Chemical family grouping
	var effect: String       # Human-readable effect description
	var severity: int        # Severity enum value
	var verified: bool       # False = "Unverified" tag shown in XIC
	var icon_path: String    # res://assets/xic/icons/<id>.png (optional)

	func _init(
		p_id: String,
		p_name: String,
		p_family: String,
		p_effect: String,
		p_severity: int,
		p_verified: bool = true,
		p_icon: String = ""
	) -> void:
		id = p_id
		compound_name = p_name
		family = p_family
		effect = p_effect
		severity = p_severity
		verified = p_verified
		icon_path = p_icon

# ─── Signals ──────────────────────────────────────────────────────────────────
## Emitted when a new compound is added mid-run (e.g. discovered from a dish).
signal new_compound_unlocked(entry: CompoundEntry)

# ─── State ────────────────────────────────────────────────────────────────────
## Full master list — never shown directly; filtered by unlocked_ids.
var _all_compounds: Array = []

## IDs the player has access to right now.
var unlocked_ids: Array[String] = []

## XIC feature unlock flags (set these via progression system).
var feature_search_unlocked: bool = false
var feature_families_unlocked: bool = false
var feature_confidence_unlocked: bool = false

# ─── Ready ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_register_all_compounds()
	_unlock_world_1_starter_set()

# ─── Public API ───────────────────────────────────────────────────────────────

## Returns only the compounds the player currently has access to.
func get_unlocked_compounds() -> Array:
	return _all_compounds.filter(func(e: CompoundEntry) -> bool:
		return e.id in unlocked_ids
	)

## Returns compounds whose name or family contains query (case-insensitive).
## Requires feature_search_unlocked.
func search(query: String) -> Array:
	if not feature_search_unlocked:
		return get_unlocked_compounds()
	var q := query.strip_edges().to_lower()
	if q.is_empty():
		return get_unlocked_compounds()
	return get_unlocked_compounds().filter(func(e: CompoundEntry) -> bool:
		return q in e.compound_name.to_lower() or q in e.family.to_lower()
	)

## Returns all compounds in a given family (requires feature_families_unlocked).
func get_family(family_name: String) -> Array:
	if not feature_families_unlocked:
		return []
	return get_unlocked_compounds().filter(func(e: CompoundEntry) -> bool:
		return e.family.to_lower() == family_name.to_lower()
	)

## Unlocks a new compound by id and emits new_compound_unlocked.
## Safe to call with an already-unlocked id (no-op).
func unlock_compound(id: String) -> void:
	if id in unlocked_ids:
		return
	var entry := _find_master(id)
	if entry == null:
		push_warning("XICDatabase: tried to unlock unknown compound id '%s'" % id)
		return
	unlocked_ids.append(id)
	new_compound_unlocked.emit(entry)

## Convenience: look up a severity label string.
func get_severity_label(severity: int) -> String:
	return SEVERITY_LABELS.get(severity, "Unknown")

## Convenience: look up a severity colour.
func get_severity_color(severity: int) -> Color:
	return SEVERITY_COLORS.get(severity, Color.WHITE)

# ─── Private Helpers ──────────────────────────────────────────────────────────
func _find_master(id: String) -> CompoundEntry:
	for entry in _all_compounds:
		if entry.id == id:
			return entry
	return null

func _add(
	p_id: String, p_name: String, p_family: String,
	p_effect: String, p_severity: int,
	p_verified: bool = true, p_icon: String = ""
) -> void:
	_all_compounds.append(
		CompoundEntry.new(p_id, p_name, p_family, p_effect, p_severity, p_verified, p_icon)
	)

# ─── World 1: Zorgon Station ─────────────────────────────────────────────────
func _unlock_world_1_starter_set() -> void:
	unlocked_ids = [
		"bioluminite_7",
		"carapace_gelatin",
		"zorgon_moon_salt",
		"glimmer_root",
		"void_spore_alpha",
	]

func _register_all_compounds() -> void:
	# ── World 1 ──────────────────────────────────────────────────────────────
	_add(
		"bioluminite_7", "Bioluminite-7", "Bioluminescent Radicals",
		"Causes rapid cellular collapse in human-type organisms. No antidote known.",
		Severity.LETHAL, true,
		"res://assets/xic/icons/bioluminite_7.png"
	)
	_add(
		"carapace_gelatin", "Carapace Gelatin", "Chitin Derivatives",
		"Edible binding agent from insectoid exoskeletons. Safe for all carbon-based life.",
		Severity.SAFE, true,
		"res://assets/xic/icons/carapace_gelatin.png"
	)
	_add(
		"zorgon_moon_salt", "Zorgon Moon Salt", "Mineral Salts",
		"Crystalline sodium analogue mined from Zorgon's third moon. Mildly bitter. Harmless.",
		Severity.SAFE, true,
		"res://assets/xic/icons/zorgon_moon_salt.png"
	)
	_add(
		"glimmer_root", "Glimmer Root", "Bioluminescent Flora",
		"Aromatic root vegetable. Faintly luminescent when fresh. No toxicity observed.",
		Severity.SAFE, true,
		"res://assets/xic/icons/glimmer_root.png"
	)
	_add(
		"void_spore_alpha", "Void Spore Alpha", "Fungal Aerosolics",
		"Airborne spore. Hallucinogenic in concentrated doses; causes 'Taste Hallucination' status.",
		Severity.MILD, false,  # Unverified — marked accordingly in UI
		"res://assets/xic/icons/void_spore_alpha.png"
	)
	# ── World 2 (locked until unlocked via progression) ───────────────────────
	_add(
		"bloom_pollen_x", "Bloom Pollen X", "Spore Compounds",
		"Dense pollen from Bloom Nebula flora. Triggers severe respiratory distress in humans.",
		Severity.SEVERE, true,
		"res://assets/xic/icons/bloom_pollen_x.png"
	)
	_add(
		"root_cluster_sap", "Root Cluster Sap", "Botanical Exudates",
		"Sticky resinous fluid. Mildly narcotic; safe in small quantities.",
		Severity.MILD, false,
		"res://assets/xic/icons/root_cluster_sap.png"
	)
	# ── Add further world compounds here as development continues ─────────────
