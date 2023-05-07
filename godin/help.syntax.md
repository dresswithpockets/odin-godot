# 1. Godin Syntax

Godot's native interface is very tedious to use. For every class or class member
you want to define, there is a significant amount of boilerplate needed.

Godin provides a simple syntax to inform the preprocessor what bindings need to
be generated.

# 1. Classes

To declare an Extension Class to be registered with Godot's ClassDB, use the class
declaration:

    //+class Player extends Node2D
    Player :: struct {
        health: i64,
    }

Unlike in GDScript, the `extends` declaration is required and indicates what this
class inherits from. In GDScript, classes inherit from RefCounted by default.

By default, directives will always produce code in a separate file named `{FILE}_gde_backend.odin`.
For example, if the previous example was written in a file `player.odin`, then
the output bindings will be in `player_gde_backend.odin`. This behaviour can be
changed with an @-declaration in the directive:

    //+class Player extends Node2D @some_file.odin
    Player :: struct {
        health: i64,
    }

This will produce the bindings in `some_file.odin` instead of `player_gde_backend.odin`.

## 1.1 Methods

To declare an instance method for an extension class, use the method declaration:

    //+method(Player) kill()
    player_kill :: proc(self: ^Player) {
        self.health = 0
    }

Methods can have arguments, whose type arguments must be godot types:

    //+method(Player) damage(amount: int)
    player_damage :: proc(self: ^Player, amount: i64) {
        self.health -= amount
    }

Methods can have return values:

    //+method(Player) heal(self: ^Player, amount: int) -> int
    player_heal :: proc(self: ^Player, amount: i64) {
        return self.health += amount
    }

You can declare a static method by prepending `static` to a method declaration:

    //+static method(Player) do_thing(a: int, b: int) -> int
    player_do_thing :: proc(a, b: i64) -> i64 {
        return a + b
    }

## 1.2 Properties

To declare a class property getter, use the property-get declaration:

    //+property(Player) health get: int
    player_get_health :: proc(self: ^Player) -> i64 {
        return self.health
    }

Setters use similar syntax:

    //+property(Player) health set: int
    player_set_health :: proc(self: ^Player, value: i64) {
        self.health = value
    }

## 1.3 Signals

To declare a class signal, use the signal declaration:

    //+class Player extends Node2D
    Player :: struct {
        // ...

        //+signal on_kill(last_damage: int)
        killed: Signal,
    }

You can emit the signal directly, for example:

    //+method(Player) damage(amount: int)
    player_damage :: proc(self: ^Player, amount: i64) {
        self.health -= amount
        if self.health <= 0 {
            gd.emit_signal(self.killed, amount)
        }
    }

## 1.4 Enums

To declare an enum, use the enum declaration:

    //+enum(Player) PlayerState
    PlayerState :: enum {
        Alive,
        Dead,
    }
