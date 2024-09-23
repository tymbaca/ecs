package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

WORLD := ecs.new_world()

SCREEN: [2]i32 : {800, 600}

init :: proc() {
	rl.InitWindow(SCREEN.x, SCREEN.y, "smasher")
	rl.SetTargetFPS(60)

	mario_png := rl.LoadTexture("resources/mario.png")
	mushroom_png := rl.LoadTexture("resources/mushroom.png")

	ecs.register_systems(
		&WORLD,
		// 
		// Draw
		draw_sprite_system,
		debug_collider_shapes,
		debug_transform,
		// 
		// Logic
		player_movement_system,
		apply_gravity_system,
		limit_transform_in_screen_system,
	)
	//ecs.register_parallel_systems(&WORLD, ..spawn_systems(stress_test_system, 10))

	e := ecs.create_entity(
		&WORLD,
		ecs.Player_Control{},
		ecs.Movement{speed = 1000},
		ecs.Transform{pos = {200, 200}},
		ecs.Limit_Transform{},
		ecs.Sprite{texture = mario_png, size = {100, 100}, pivot = .Down},
		ecs.Simple_Gravity{force = 800},
		ecs.Collider{shape = ecs.Box{size = {80, 100}}, pivot = .Down},
	)
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
