package ecs

import "base:intrinsics"

World :: struct($T: typeid) {
	entities:   [dynamic]Entity,
	components: map[typeid]map[int]T,
	systems:    [dynamic]proc(g: ^World(T)),
}

new_world :: proc($T: typeid) -> World(T) where intrinsics.type_is_union(T) {
	return World(T) {
		entities = make([dynamic]Entity),
		components = make(map[typeid]map[int]T),
		systems = make([dynamic]proc(g: ^World(T))),
	}
}
