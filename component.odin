package ecs

import "core:fmt"

ComponentStorage :: map[typeid]map[int]Component

type_to_kind := map[typeid]ComponentKind {
	PlayerControl = .PlayerControl,
	Movement      = .Movement,
	Health        = .Health,
	Platform      = .Platform,
	Collider      = .Collider,
	Gravity       = .Gravity,
	Transform     = .Transform,
	Sprite        = .Sprite,
}

kind_to_type := map[ComponentKind]typeid {
	.PlayerControl = PlayerControl,
	.Movement      = Movement,
	.Health        = Health,
	.Platform      = Platform,
	.Collider      = Collider,
	.Gravity       = Gravity,
	.Transform     = Transform,
	.Sprite        = Sprite,
}

get_component :: proc(store: ComponentStorage, id: int, $T: typeid) -> (T, bool) #optional_ok {
	component_map, ok := store[T]
	assert(ok, fmt.aprintf("no component map of type %T", T{}))

	component: Component
	component, ok = component_map[id]
	if !ok {
		return T{}, false
	}

	final_component: T
	final_component, ok = component.(T)
	assert(ok, fmt.aprintf("got incorrent component type in map of type %T", T{}))

	return final_component, true
}

add_component :: proc(w: World, e: Entity, c: $T) {
	fmt.println(typeid_of(type_of(c)))
	m := w.components[typeid_of(type_of(c))]
	m[e.id] = c
}

ComponentKind :: enum {
	PlayerControl,
	Movement,
	Health,
	Platform,
	Collider,
	Gravity,
	Transform,
	Sprite,
}

Component :: union {
	int,
	PlayerControl,
	Movement,
	Health,
	Platform,
	Collider,
	Gravity,
	Transform,
	Sprite,
}

PlayerControl :: struct {
	speed: int,
}
Movement :: struct {}
Health :: struct {}
Platform :: struct {}
Collider :: struct {}
Gravity :: struct {}
Transform :: struct {}
Sprite :: struct {}
