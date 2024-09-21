package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

WORLD := ecs.new_world()

init :: proc() {
	rl.InitWindow(800, 600, "smasher")
	rl.SetTargetFPS(60)

	mario_png := rl.LoadTexture("resources/mario.png")
	mushroom_png := rl.LoadTexture("resources/mushroom.png")

	ecs.register_systems(
		&WORLD,
		player_movement_system,
		draw_sprite_system,
		apply_physics_system,
		apply_gravity_system,
	)

	e := ecs.create_entity(
		&WORLD,
		ecs.Player_Control{},
		ecs.Movement{speed = 10},
		ecs.Transform{},
		ecs.Sprite{texture = mario_png, scale = 0.1},
		ecs.Gravity{force = 0.98},
		ecs.Physics{vertical_active = true},
	)
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		ecs.log(WORLD)

		update(&WORLD)

		rl.DrawFPS(0, 0)

		rl.EndDrawing()
	}
}

update :: proc(world: ^ecs.World) {
	for system in world.systems {
		system(world)
	}
}
