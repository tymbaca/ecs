package main

import ".."
import "core:fmt"
import rl "vendor:raylib"


WORLD := ecs.new_world(Component)

main :: proc() {
	mainIlligal()
}

mainBus :: proc() {
	ecs.create_entity(
		&WORLD,
		Player_Control{},
		Movement{speed = 1.0},
		Box{size = {40, 50}, color = rl.RED},
		Transform{},
	)

	fmt.println("agter entity create")
}

mainIlligal :: proc() {
	ecs.create_entity(
		&WORLD,
		Player_Control{},
		Movement{speed = 1.0},
		/*
		Box{size = {40, 50}, color = rl.RED},
		Transform{},
        */
	)

	fmt.println("agter entity create")
}

mainSegFault :: proc() {
	ecs.create_entity(
		&WORLD,
		Movement{speed = 1.0},
		Box{size = {40, 50}, color = rl.RED},
		Transform{},
		Player_Control{}, // moved this to last position
	)

	fmt.println("agter entity create")
}
