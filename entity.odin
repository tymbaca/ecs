package ecs

import "core:fmt"

// Entity represents the Entity :) It holds it's ID and flags of 
// components that it has
Entity :: struct {
	id:         int,
	components: ComponentSet,
}

// ComponentSet is a set of flags of component types that entity owns
ComponentSet :: map[typeid]struct {}

// create_entity creates new entity with specified components, adds it to world and returns it
create_entity :: proc(world: ^World($T), components: ..T) {
	fmt.printf("%T, %v", components, components)
	/*
	e := new_entity()

	for comp in components {
		set_component(world, &e, comp)
	}

	append(&world.entities, e)
    */

	//return Entity{}
}

new_entity :: proc(id := 7) -> Entity {
	e := Entity {
		id         = id,
		components = make(ComponentSet),
	}

	return e
}

has_components :: proc(e: Entity, types: ..typeid) -> bool {
	for t in types {
		if t not_in e.components {
			return false
		}
	}

	return true
}
