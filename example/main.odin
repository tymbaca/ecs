package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

World :: ecs.World(Component)
WORLD := ecs.new_world(Component)

System :: proc(w: ^World)

init :: proc() {
	rl.InitWindow(800, 600, "smasher")
	//rl.SetTargetFPS(60)

	mario_png := rl.LoadTexture("resources/mario.png")
	mushroom_png := rl.LoadTexture("resources/mushroom.png")

	ecs.register_systems(&WORLD, player_movement_system)
	/*
	ecs.register_systems(&WORLD, ..spawn_systems(stress_test_system, 10))
    */
	ecs.register_parallel_systems(
		&WORLD,
		..spawn_parallel_systems(ecs.to_parallel_system(stress_test_system), 10),
	)

	e := ecs.create_entity(&WORLD, Player_Control{}, Movement{speed = 10}, Transform{})
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		ecs.log(WORLD)

		ecs.update(&WORLD)

		rl.DrawFPS(0, 0)

		rl.EndDrawing()
	}
}
