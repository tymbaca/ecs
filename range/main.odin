package main

import ".."
import "base:runtime"
import "core:fmt"
import "core:os"

main :: proc() {
	when ODIN_DEBUG {
		name: string
	}

	name = "fsd"

	fmt.println(name)
	/*
	w := ecs.new_world()
	w.components = ecs.ComponentStorage {
		ecs.Player_Control = {7 = ecs.Player_Control{}, 6 = ecs.Movement{}},
	}
	e := ecs.new_entity()

	//ecs.set_component(&w, &e, ecs.PlayerControl{})

	pc := ecs.get_component(w, 7, ecs.Player_Control)

	pc2 := ecs.get_component(w, 6, ecs.Player_Control)
    */
	//--------------------------------------------------------------------------------------------------

}

log_types :: proc(Ts: ..typeid) {
	for t in Ts {
		fmt.println(t)
	}
}
