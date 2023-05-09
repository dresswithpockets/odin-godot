package test

//+class Player extends Node2D
Player :: struct {
    health: i64,
}

player_kill :: proc(self: ^Player) {
    self.health = 0
}
