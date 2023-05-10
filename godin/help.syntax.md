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

By default, directives will always produce code in a separate file named `{FILE}.gen.odin`.
For example, if the previous example was written in a file `player.odin`, then
the output bindings will be in `player.gen.odin`.

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

### 1.1.1 Special Methods

You may override the default behaviour of some pre-defined methods by name:

    //+method(Player) _set(property: StringName, value: Variant) -> bool
    player_set :: proc(self: ^Player, property: var.StringName, value: var.Variant) -> bool {
        // check property name and field value on self
        // return true if property found & set, false otherwise
    }

These are the methods you may override by name:

    _init()
    _notification(what: int)
    _set(property: StringName, value: Variant) -> bool
    _get(property: StringName, value: ^Variant) -> bool
    _get_property_list() -> Dictionary
    _property_can_revert(name: StringName) -> bool
    _property_get_revert(name: StringName, value: ^Variant) -> bool
    _to_string() -> String

See https://docs.godotengine.org/en/latest/classes/class_object.html for more
details on these methods

You may also override `_destroy`, which will be called when the object is freed.

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
