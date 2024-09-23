package component

Health :: struct {
	health: f32,
}

Player_Control :: struct {}

Movement :: struct {
	speed: f32,
}

Jump :: struct {
	power:            f32,
	current_velocity: f32,
	falloff:          f32,
	busy:             bool,
}
