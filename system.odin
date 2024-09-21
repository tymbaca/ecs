package ecs

System :: proc(g: ^World)

draw_sprite_system :: proc(w: ^World) {
	query := bit_set[ComponentKind]{.Sprite}

	for e in w.entities {
	}
}
