extends SceneTree

const SaveSystem = preload("res://scripts/core/save_system.gd")
const Explore = preload("res://scripts/core/explore.gd")

func _init() -> void:
	print("--- TEST LOAD PROFILE SAVE.JSON ---")
	var p = SaveSystem.load_profile()
	if p == null:
		printerr("FAIL: khong load duoc save")
		quit(1)
		return
	print("Profile name: ", p.name)
	print("Total tiles: ", p.tiles.size())
	print("Explore total: ", Explore.explore_total(p.tiles))
	print("Explore owned: ", Explore.owned_count(p.tiles))
	SaveSystem.save_profile(p)
	print("DA LUU LAI SAVE HOAN CHINH!")
	quit(0)

