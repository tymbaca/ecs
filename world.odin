package ecs

World :: struct {
	entities:   [dynamic]Entity,
	components: ComponentStorage,
	systems:    [dynamic]System,
}

W := World {
	entities   = make([dynamic]Entity),
	components = make(ComponentStorage),
	systems    = make([dynamic]System),
}
