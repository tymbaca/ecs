package main

import ".."
import "base:runtime"
import "core:fmt"
import "core:os"

main :: proc() {
	s: [dynamic]int

	append(&s, 10)
	fmt.println(s)
	/*
	m: map[string]int

	clear(&m)

	v := m["hello"]
	fmt.println(v)

	m["hello"] = 11
	v = m["hello"]
	fmt.println(v)

	clear(&m)

	v = m["hello"]
	fmt.println(v)
    */
	/*
	w := ecs.new_world()
	w.components = ecs.ComponentStorage {
		ecs.Player_Control = {7 = ecs.Player_Control{}, 6 = ecs.Movement{}},
	}
	e := ecs.new_entity()

	//ecs.set_component(&w, &e, ecs.PlayerControl{})

	pc := ecs.get_component(w, 7, ecs.Player_Control)
	ecs.log(pc)

	pc2 := ecs.get_component(w, 6, ecs.Player_Control)
	ecs.log(pc2)
    */
	//--------------------------------------------------------------------------------------------------

}
