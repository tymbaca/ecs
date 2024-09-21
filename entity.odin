package ecs

Entity :: struct {
	id:         int,
	components: ComponentSet,
}

ComponentSet :: map[typeid]struct {}

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
