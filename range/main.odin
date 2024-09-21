package main

import ".."
import "core:fmt"

main :: proc() {
	w := ecs.new_world()
	w.components = ecs.ComponentStorage {
		ecs.PlayerControl = {7 = ecs.Player_Control{}, 6 = ecs.Movement{}},
	}
	e := ecs.new_entity(6)

	//ecs.set_component(&w, &e, ecs.PlayerControl{})

	pc := ecs.get_component(w, 7, ecs.Player_Control)
	ecs.log(pc)

	pc2 := ecs.get_component(w, 6, ecs.Player_Control)
	ecs.log(pc2)
	/*
    */
}
