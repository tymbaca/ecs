package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

World :: ecs.World(Component)

WORLD: World = ecs.new_world(Component)

init :: proc() {
	ecs.register_systems(&WORLD, player_movement_system)
	e := ecs.new_entity()
	ecs.set_component(&WORLD, &e, PlayerControl{})
	ecs.set_component(&WORLD, &e, Movement{speed = 5})
	ecs.set_component(&WORLD, &e, Transform{})

	append(&WORLD.entities, e)
}

main :: proc() {
	init()

	rl.InitWindow(800, 600, "smasher")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		ecs.log(WORLD)

		update(&WORLD)
		/*
        */

		rl.DrawFPS(0, 0)

		rl.EndDrawing()
	}
}

update :: proc(world: ^World) {
	for system in world.systems {
		system(world)
	}
}
