package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	p := ecs.get_component(ecs.W.components, 12, ecs.PlayerControl)

	rl.InitWindow(800, 600, "smasher")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)


		rl.EndDrawing()
	}
}
