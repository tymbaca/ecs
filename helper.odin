package ecs

import "core:fmt"

DEBUG :: #config(ECS_DEBUG, false)

log :: proc(args: ..any) {
    when DEBUG {
        fmt.println(..args)
    }
}
