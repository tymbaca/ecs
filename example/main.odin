package main

import ".."
import "core:fmt"
import rl "vendor:raylib"


WORLD := ecs.new_world(Component)

main :: proc() {

	/*
    */
	ecs.create_entity(
		&WORLD,
		Player_Control{},
		Movement{speed = 1.0},
		Box{size = {40, 50}, color = rl.RED},
		Transform{},
	)

	fmt.println("after entity create")
	fmt.println(WORLD)
}
