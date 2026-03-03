package ecs

import "core:fmt"

DEBUG :: true

log :: proc(args: ..any) {
    if DEBUG {
        fmt.println(..args)
    }
}
