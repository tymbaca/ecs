package ecs

import "core:fmt"
DEBUG :: true

log :: proc(args: ..any) {
    fmt.println(..args)
}
