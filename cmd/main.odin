package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

WORLD := ecs.new_world()

init :: proc() {
	rl.InitWindow(800, 600, "smasher")

	mario_png := rl.LoadTexture("resources/mario.png")
	mushroom_png := rl.LoadTexture("resources/mushroom.png")

	ecs.register_systems(&WORLD, player_movement_system, draw_sprite_system)

	e := ecs.create_entity(
		&WORLD,
		ecs.PlayerControl{},
		ecs.Movement{speed = 5},
		ecs.Transform{},
		ecs.Sprite{texture = mario_png},
	)
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

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
