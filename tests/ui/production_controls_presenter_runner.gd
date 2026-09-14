extends SceneTree

const PRESENTER: Script = preload("res://scripts/ui/production_controls_presenter.gd")


func _initialize() -> void:
	var translate := func(key: String) -> String: return TranslationServer.translate(key)
	for locale in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		for quantity in [1, 10]:
			var state: Dictionary = {
				"quantity": quantity, "finished": false, "capacity": quantity, "max_orders": 3,
			}
			for kind in ["skeleton", "archer", "zombie"]:
				state[kind] = {
					"cost": 5, "available": 5 * quantity, "unlocked": true, "orders": 2,
					"title": "PRODUCTION_QUEUE_" + kind.to_upper(),
					"resource": "RESOURCE_FLESH" if kind == "zombie" else "RESOURCE_BONES",
				}
			var original: Dictionary = state.duplicate(true)
			var view: Dictionary = PRESENTER.production(state, translate)
			assert(state == original, "Presenter must not mutate match snapshots")
			assert(view.editable)
			assert(view.prefix == str(translate.call("PRODUCTION_QUANTITY")) + ": ")
			for kind in ["skeleton", "archer", "zombie"]:
				assert(not view[kind].disabled)
				assert(view[kind].text.contains("x" + str(quantity)))
				assert(view[kind].text.contains("\n" + str(5 * quantity) + " "))
				state[kind].available -= 1
				assert(PRESENTER.production(state, translate)[kind].disabled)
				state[kind].available += 1
				state[kind].orders = 3
				assert(PRESENTER.production(state, translate)[kind].disabled)
				state[kind].orders = 2
			state.archer.unlocked = false
			view = PRESENTER.production(state, translate)
			assert(view.archer.disabled)
			assert(view.archer.text == str(translate.call("PRODUCTION_ARCHER_LOCKED")))
			state.capacity = quantity - 1
			view = PRESENTER.production(state, translate)
			assert(view.skeleton.disabled and view.zombie.disabled)
			state.capacity = quantity
			state.finished = true
			view = PRESENTER.production(state, translate)
			assert(not view.editable and view.skeleton.disabled and view.zombie.disabled)
		var processing: Dictionary = {
			"directive": "Balanced", "locked": true, "corpses": 12,
			"bones": 8, "flesh": 2, "queued": 3, "capacity": 5, "seconds": 0.65,
		}
		var text: String = PRESENTER.processing(processing, translate)
		assert(text.contains(str(translate.call("PROCESSING_LOCKED_WAVE"))))
		assert(text.contains("3 / 5") and text.contains("+8") and text.contains("+2"))
		processing.locked = false
		assert(PRESENTER.processing(processing, translate).contains(
			str(translate.call("PROCESSING_CHOOSE_NEXT"))
		))
		assert(PRESENTER.queue_status([2, 0.5, 3, 0.2], translate) ==
			str(translate.call("PRODUCTION_QUEUE_STATUS")) % [2, 0.5, 3, 0.2])
	print("PRODUCTION CONTROLS PRESENTER VALIDATION: PASS")
	quit()
