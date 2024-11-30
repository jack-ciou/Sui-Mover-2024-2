module kapy_adventure::kapy_world;

// Dependencies

use std::type_name::{Self, TypeName};
use sui::vec_map::{Self, VecMap};
use sui::sui::SUI;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use kapy_adventure::events;

// Constants

const SHIP_PRICE: u64 = 10_000_000_000;
const TREASURE_AMOUNT: u64 = 10_000_000_000;

// Object

public struct KapyWorld has key {
    id: UID,
    pirate_rules: VecMap<u8, TypeName>,
    crew_supply: u32,
    strength_threshold: u16,
    treasury: Balance<SUI>,
}

// Capability

public struct GodPower has key, store {
    id: UID,
}

// Constructor

fun init(ctx: &mut TxContext) {
    // share Config
    let world = KapyWorld {
        id: object::new(ctx),
        pirate_rules: vec_map::empty(),
        crew_supply: 0,
        strength_threshold: 31,
        treasury: balance::zero(),
    };
    transfer::share_object(world);

    // transfer GodPower to deployer
    let power = GodPower {
        id: object::new(ctx),
    };
    transfer::transfer(power, ctx.sender());
}

// Public Funs

public fun add_treasure(
    world: &mut KapyWorld,
    treasure: Coin<SUI>,
) {
    events::emit_add_treasure(treasure.value());
    coin::put(&mut world.treasury, treasure);
}

// Admin Funs

public fun add_pirate_rule<R: drop>(
    world: &mut KapyWorld,
    _cap: &GodPower,
    kind: u8,
) {
    world.pirate_rules.insert(kind, type_name::get<R>());
}

public fun remove_pirate_rule(
    world: &mut KapyWorld,
    _cap: &GodPower,
    kind: u8,
) {
    world.pirate_rules.remove(&kind);
}

public fun set_strength_threshold(
    world: &mut KapyWorld,
    _cap: &GodPower,
    threshold: u16,
) {
    world.strength_threshold = threshold;
}

// Package Funs

public(package) fun take_treasure(
    world: &mut KapyWorld,
    ctx: &mut TxContext,
): Coin<SUI> {
    coin::take(&mut world.treasury, treasure_amount(), ctx)
}

public(package) fun add_crew(
    world: &mut KapyWorld,
) {
    world.crew_supply = world.crew_supply() + 1;
}

// Getter Funs

public fun ship_price(): u64 { SHIP_PRICE }

public fun treasure_amount(): u64 { TREASURE_AMOUNT }

public fun pirate_rules(world: &KapyWorld): &VecMap<u8, TypeName> {
    &world.pirate_rules
}

public fun crew_supply(world: &KapyWorld): u32 {
    world.crew_supply
}

public fun treasury(world: &KapyWorld): &Balance<SUI> {
    &world.treasury
}

public fun strength_threshold(world: &KapyWorld): u16 {
    world.strength_threshold
}

public fun is_valid_pirate_rule<R: drop>(
    world: &KapyWorld,
    kind: u8,
): bool {
    if (world.pirate_rules().contains(&kind)) {
        let rule_name = world.pirate_rules().get(&kind);
        rule_name == type_name::get<R>()
    } else {
        false
    }
}

// Test-only Funs

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}

#[test_only]
public fun add_pirate_rule_for_testing<R: drop>(
    world: &mut KapyWorld,
    kind: u8,
) {
    world.pirate_rules.insert(kind, type_name::get<R>());
}
