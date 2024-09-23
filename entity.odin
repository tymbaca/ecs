package ecs

import cmp "component"

Entity :: struct {
	id:         int,
	components: ComponentSet,
}

ComponentSet :: map[typeid]struct {}

// create_entity creates new entity with specified components, adds it to world and returns it
create_entity :: proc(world: ^World, components: ..cmp.Component) -> Entity {
	e := new_entity()

	for comp in components {
		set_component(world, &e, comp)
	}

	append(&world.entities, e)

	return e
}

new_entity :: proc() -> Entity {
	@(static)id := 0
	id += 1

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
