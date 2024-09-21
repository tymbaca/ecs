package main

import ".."
import "core:fmt"

main :: proc() {
	store := ecs.ComponentStorage {
		ecs.PlayerControl = {7 = ecs.PlayerControl{speed = 100}, 6 = ecs.Movement{}},
	}

	w := ecs.W
	e := ecs.new_entity(6)

	//ecs.add_component(w, e, ecs.PlayerControl{speed = 166})

	pc := ecs.get_component(store, 7, ecs.PlayerControl)
	fmt.println(pc)
	pc2 := ecs.get_component(store, 6, ecs.PlayerControl)
	fmt.println(pc2)
}
