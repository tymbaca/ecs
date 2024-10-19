package ecs

import "core:fmt"
import "core:reflect"

// `set_component` created of replaces (if it already exists) the component on the entity.
set_component :: proc(world: ^World($Component), entity: ^Entity, component: Component) {
	component_type := reflect.union_variant_typeid(component)

	// Add component to storage
	comp_map := world.components[component_type]
	comp_map[entity.id] = component
	world.components[component_type] = comp_map // in case of map evacuation

	// Set component flag on entity
	entity.components[component_type] = {}
}

// `update_component` updates the component on entity with passed id. If there is no
// such component on that entity or if entity with id doesn't exist - it's no-op.
update_component :: proc(world: ^World($Component), id: int, component: Component) {
	component_type := reflect.union_variant_typeid(component)

	comp_map := world.components[component_type]
    if id in comp_map {
        comp_map[id] = component
    }
	world.components[component_type] = comp_map // in case of map evacuation
}

/* DOESN'T WORK
set_component_concrete :: proc(world: ^World, entity: ^Entity, component: $T) {
	component_type := typeid_of(type_of(component))

	// Init comp_map of that type if it doesn't exist
	if world.components[component_type] == nil {
		world.components[component_type] = make(map[int]Component)
	}

	// Add component to storage
	comp_map := world.components[component_type]
	comp_map[entity.id] = component
	world.components[component_type] = comp_map // in case of map evacuation

	// Set component flag on entity
	entity.components[component_type] = {}
}
*/

// `must_get_component` is the same as get_component but it panics if not found
must_get_component :: proc(
	w: World($Component),
	entity_id: int,
	$T: typeid,
	loc := #caller_location,
) -> T {
	comp, ok := get_component(w, entity_id, T)
	if !ok {
		panic(fmt.aprintf("can't get component, caller: %v", loc))
	}

	return comp
}

// `get_component` gets the entity's component of specified type
get_component :: proc(w: World($Component), entity_id: int, $T: typeid) -> (T, bool) #optional_ok {
	component_map, ok := w.components[T]
	if !ok {
		return T{}, false
	}

	// Get union component from map
	component: Component
	component, ok = component_map[entity_id]
	if !ok {
		return T{}, false
	}

	// Convert component to concrete type
	final_component: T
	final_component, ok = component.(T)
	if !ok {
		assert(
			ok,
			fmt.aprintf(
				"got incorrent component type (%v) in map of type %T",
				reflect.union_variant_typeid(component),
				T{},
			),
		)
	}

	return final_component, true
}
