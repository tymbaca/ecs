package main

import ".."
import "core:fmt"
import rl "vendor:raylib"


WORLD := ecs.new_world(Component)

init :: proc() {
	e1 := ecs.create_entity(
	&WORLD,
	Player_Control{},
	Movement{speed = 1.0},
	Transform{},
	Box{size = {40, 50}, color = rl.RED},
	/*
        */
	)

	/*
	ecs.create_entity(
		&WORLD,
		Player_Control{},
		Movement{speed = 1},
		Transform{pos = {100, 100}},
		Box{size = {40, 50}, color = rl.BLUE},
	)

	ecs.create_entity(
		&WORLD,
		Movement{speed = 1},
		Transform{pos = {200, 300}},
		Box{size = {20, 30}, color = rl.GREEN},
	)
    */

	ecs.register_systems(&WORLD, player_movement_system, draw_box_system)
}

main :: proc() {
	init()

	/*
	rl.InitWindow(800, 600, "smasher")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		ecs.log(WORLD)

		update(&WORLD)

		rl.DrawFPS(0, 0)

		rl.EndDrawing()
	}
    */
}

update :: proc(world: ^ecs.World(Component)) {
	for system in world.systems {
		system(world)
	}
}
