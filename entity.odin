package ecs

import cmp "component"
import "entity"

// create_entity creates new entity with specified components, adds it to world and returns it
create_entity :: proc(world: ^World, components: ..cmp.Component) -> entity.Entity {
	e := new_entity()

	for comp in components {
		set_component(world, &e, comp)
	}

	append(&world.entities, e)

	return e
}

new_entity :: proc() -> entity.Entity {
	@(static)id := 0
	id += 1

	e := entity.Entity {
		id         = id,
		components = make(entity.ComponentSet),
	}

	return e
}

has_components :: proc(e: entity.Entity, types: ..typeid) -> bool {
	for t in types {
		if t not_in e.components {
			return false
		}
	}

	return true
}
