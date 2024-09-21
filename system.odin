package ecs

import rl "vendor:raylib"

register_systems :: proc(w: ^World($C), systems: ..proc(g: ^World(C))) {
	append(&w.systems, ..systems)
}
