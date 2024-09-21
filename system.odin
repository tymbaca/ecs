package ecs

import rl "vendor:raylib"

// TODO add delta
//System :: proc(g: ^World)

register_systems :: proc(w: ^World($C), systems: ..proc(g: ^World(C))) {
	append(&w.systems, ..systems)
}
