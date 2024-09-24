package main

import ".."
import cmp "component"
import "core:fmt"
import rl "vendor:raylib"

World :: ecs.World(cmp.Component)
WORLD := ecs.new_world(cmp.Component)

SCREEN: [2]i32 : {800, 600}

init :: proc() {
	rl.InitWindow(SCREEN.x, SCREEN.y, "smasher")
	//rl.SetTargetFPS(60)

	mario_png := rl.LoadTexture("resources/mario.png")
	mushroom_png := rl.LoadTexture("resources/mushroom.png")

	ecs.register_systems(
		&WORLD,
		// 
		// Draw
		draw_sprite_system,
		// Debug draw
		debug_collider_shapes,
		debug_transform,
		player_movement_system,
		apply_gravity_system,
		jump_system,
		limit_transform_in_screen_system,
	)
	/*
	ecs.register_parallel_systems(
		&WORLD,
		// 
		// Logic
		ecs.to_parallel_system(player_movement_system),
		ecs.to_parallel_system(apply_gravity_system),
		ecs.to_parallel_system(jump_system),
		ecs.to_parallel_system(limit_transform_in_screen_system),
	)
    */

	e := ecs.create_entity(
		&WORLD,
		cmp.Player_Control{},
		cmp.Movement{speed = 1000},
		cmp.Transform{pos = {200, 200}},
		cmp.Limit_Transform{},
		cmp.Sprite{texture = mario_png, size = {100, 100}, pivot = .Down},
		cmp.Simple_Gravity{force = 1000},
		cmp.Collider{shape = cmp.Box{size = {80, 100}}, pivot = .Down},
		cmp.Jump{power = 2600, falloff = 2600},
	)
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		ecs.log(WORLD)
		ecs.update(&WORLD)

		//rl.DrawFPS(0, 0)
		rl.EndDrawing()
	}
}
