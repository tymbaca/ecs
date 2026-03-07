package colliders

import "core:testing"
import "core:math/linalg"
import rl "vendor:raylib"

Circle :: struct {
    center: [2]f32,
    radius: f32,
}

calculate_bounding_circle :: proc(c1, c2: Circle) -> Circle {
    dist := linalg.distance(c1.center, c2.center)

    if dist + c1.radius <= c2.radius do return c2
    if dist + c2.radius <= c1.radius do return c1

    radius := (c1.radius + c2.radius + dist) / 2
    center := c1.center + (c2.center - c1.center) * (radius - c1.radius) / dist

    return {center, radius}
}

@(test)
calculate_bounding_circle_test :: proc(t: ^testing.T) {
    testing.expect_value(t, calculate_bounding_circle({{10, 10}, 5}, {{10, 10}, 3}), Circle{{10, 10}, 5})
    testing.expect_value(t, calculate_bounding_circle({{10, 10}, 5}, {{10, 10}, 5}), Circle{{10, 10}, 5})
    testing.expect_value(t, calculate_bounding_circle({{10, 10}, 5}, {{10, 10}, 5.7}), Circle{{10, 10}, 5.7})
    testing.expect_value(t, calculate_bounding_circle({{0, 0}, 5}, {{10, 0}, 5}), Circle{{5, 0}, 10})
    testing.expect_value(t, calculate_bounding_circle({{-5, 0}, 0}, {{5, 0}, 0}), Circle{{0, 0}, 5}) // dots
}

get_circle_growth :: proc(into, v: Circle) -> f32 {
    return calculate_bounding_circle(into, v).radius - into.radius
}

circles_intersect :: proc(a, b: Circle) -> bool {
    return linalg.distance(a.center, b.center) < a.radius + b.radius
}

bounce :: proc(c1: Circle, v1: Velocity, c2: Circle, v2: Velocity) -> (new_v1: Velocity, new_v2: Velocity) {
    // Normal vector from c1 to c2 (line of centers)
    n := c2.center - c1.center
    dist_sq := linalg.length2(n)
    if dist_sq < 1e-6 { // nearly coincident – avoid division by zero
        return v1, v2
    }
    n = linalg.normalize(n)

    // Masses proportional to area (radius²)
    m1 := c1.radius * c1.radius
    m2 := c2.radius * c2.radius

    // Decompose velocities into normal and tangential components
    v1n := linalg.dot(v1, Velocity(n))
    v2n := linalg.dot(v2, Velocity(n))
    v1t := v1 - v1n * Velocity(n)
    v2t := v2 - v2n * Velocity(n)

    // New normal velocities after 1D elastic collision
    v1n_new := ((m1 - m2) * v1n + 2 * m2 * v2n) / (m1 + m2)
    v2n_new := ((m2 - m1) * v2n + 2 * m1 * v1n) / (m1 + m2)

    // Combine with unchanged tangential components
    new_v1 = v1n_new * Velocity(n) + v1t
    new_v2 = v2n_new * Velocity(n) + v2t
    return
}
