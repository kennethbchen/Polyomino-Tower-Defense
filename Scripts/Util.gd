extends Node

class_name Util

# Towers themselves exist on layer 1
# Enemies exist on collision layer 2
# Tower projectiles exist on collision layer 3

# Layer 1 is weird and sometimes things are detected even though they aren't on layer 1

const board_width = 10
const board_height = 16

const NAV_ALLOWED_TILE = 1
const NAV_BLOCKED_TILE = 2
