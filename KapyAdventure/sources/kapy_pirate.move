module kapy_adventure::kapy_pirate;

// Dependencies

use sui::package;
use kapy_adventure::kapy_world::{KapyWorld, GodPower};
use kapy_adventure::events;

// Errors

const EInvalidPirateRule: u64 = 0;
fun err_invalid_pirate_rule() { abort EInvalidPirateRule }

// One Time Witness

public struct KAPY_PIRATE has drop {}

// Object (NFT)

public struct KapyPirate has key, store {
    id: UID,
    kind: u8,
}

// Constructor

fun init(otw: KAPY_PIRATE, ctx: &mut TxContext) {
    package::claim_and_keep(otw, ctx);
}

// Public Funs

public fun new<R: drop>(
    world: &KapyWorld,
    kind: u8,
    _rule_witness: R,
    ctx: &mut TxContext,
): KapyPirate {
    if (!world.is_valid_pirate_rule<R>(kind)) {
        err_invalid_pirate_rule();
    };
    new_internal(kind, ctx)
}

// Package Funs

public(package) fun get_recruited(pirate: KapyPirate): u8 {
    let KapyPirate { id, kind } = pirate;
    object::delete(id);
    kind
}

// Admin Funs

public fun new_by_god(
    _cap: &GodPower,
    kind: u8,
    ctx: &mut TxContext,
): KapyPirate {
    new_internal(kind, ctx)
}

entry fun new_by_god_to(
    _cap: &GodPower,
    kind: u8,
    recipient: address,
    ctx: &mut TxContext,
) {
    let pirate = new_internal(kind, ctx);
    transfer::transfer(pirate, recipient);
}

//  Getter Funs

public fun kind(pirate: &KapyPirate): u8 {
    pirate.kind
}

// Internal Funs

public fun new_internal(kind: u8, ctx: &mut TxContext): KapyPirate {
    let id = object::new(ctx);
    events::emit_new_pirate(id.to_inner(), kind);
    KapyPirate { id, kind }
}