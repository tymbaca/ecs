package ecs

import rl "vendor:raylib"

System :: proc(g: ^World) // TODO add delta

register_systems :: proc(w: ^World, systems: ..System) {
	append(&w.systems, ..systems)
}
