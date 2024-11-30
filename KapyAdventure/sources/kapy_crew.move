module kapy_adventure::kapy_crew;

// Dependencies

use std::string::{String, utf8};
use std::u64::pow;
use sui::display;
use sui::package;
use sui::vec_set::{Self, VecSet};
use sui::sui::SUI;
use sui::coin::Coin;
use kapy_adventure::kapy_world::{Self, KapyWorld, GodPower};
use kapy_adventure::kapy_pirate::{Self, KapyPirate};
use kapy_adventure::events;
// Errors

const ERecruitSameKindOfPirate: u64 = 0;
fun err_recruit_same_kind_of_pirate() { abort ERecruitSameKindOfPirate }

const ENotEnoughFundToBuildCrew: u64 = 1;
fun err_not_enough_fund_to_build_crew() { abort ENotEnoughFundToBuildCrew }

const EAlreadyFoundTreasure: u64 = 2;
fun err_already_found_treasure() { abort EAlreadyFoundTreasure }

const ETooWeakToFindTreasure: u64 = 3;
fun err_too_weak_to_find_treasure() { abort ETooWeakToFindTreasure }

// One Time Witness

public struct KAPY_CREW has drop {}

// Object (NFT)

public struct KapyCrew has key, store {
    id: UID,
    index: u32,
    name: String,
    members: VecSet<u8>,
    strength: u16,
    found_treasure: bool,
}

// Constructor

fun init(otw: KAPY_CREW, ctx: &mut TxContext) {
    // setup Kapy display
    let keys = vector[
        utf8(b"name"),
        utf8(b"description"),
        utf8(b"image_url"),
        utf8(b"project_url"),
        utf8(b"creator"),
    ];

    let values = vector[
        // name
        utf8(b"Kapy Crew: {name}"),
        // description
        utf8(b"Complete exercises to recruit pirates and go find treasure!"),
        // image_url
        utf8(
            b"https://aqua-natural-grasshopper-705.mypinata.cloud/ipfs/Qmd9RpFKPBDzHdfnq7HSdhND9svg1fJxr7GAwTYwfEr5vh/KapyCrew_{strength}.png",
        ),
        // project_url
        utf8(b"https://lu.ma/eajq2r68"),
        // creator
        utf8(b"Bucket X Typus"),
    ];

    let deployer = ctx.sender();
    let publisher = package::claim(otw, ctx);
    let mut displayer = display::new_with_fields<KapyCrew>(
        &publisher,
        keys,
        values,
        ctx,
    );
    display::update_version(&mut displayer);

    transfer::public_transfer(displayer, deployer);
    transfer::public_transfer(publisher, deployer);
}

// Public Funs

public fun build_crew(
    world: &mut KapyWorld,
    fund: Coin<SUI>,
    name: String,
    ctx: &mut TxContext,
): KapyCrew {
    if (fund.value() < kapy_world::ship_price()) {
        err_not_enough_fund_to_build_crew();
    };
    world.add_treasure(fund);
    build_crew_internal(world, name, ctx)
}

public fun build_crew_by_god(
    world: &mut KapyWorld,
    _cap: &GodPower,
    name: String,
    ctx: &mut TxContext,
): KapyCrew {
    build_crew_internal(world, name, ctx)
}

public fun update_name(crew: &mut KapyCrew, name: String) {
    crew.name = name;
}

public fun recruit(crew: &mut KapyCrew, pirate: KapyPirate) {
    let pirate_kind = kapy_pirate::get_recruited(pirate);
    if (crew.members().contains(&pirate_kind)) {
        err_recruit_same_kind_of_pirate();
    };
    crew.members.insert(pirate_kind);
    crew.strength = get_strength(crew.members);
    events::emit_recruit(
        object::id(crew),
        crew.index(),
        crew.strength(),
        pirate_kind,
    );
}

public fun get_treasure(
    crew: &mut KapyCrew,
    world: &mut KapyWorld,
    ctx: &mut TxContext,
): Coin<SUI> {
    if (crew.found_treasure()) {
        err_already_found_treasure();
    };
    if (crew.strength() < world.strength_threshold()) {
        err_too_weak_to_find_treasure();
    };
    crew.found_treasure = true;
    events::emit_found_treasure(
        object::id(crew),
        crew.index(),
        crew.strength(),
    );
    world.take_treasure(ctx)
}

//  Getter Funs

public fun index(crew: &KapyCrew): u32 {
    crew.index
}

public fun name(crew: &KapyCrew): String {
    crew.name
}

public fun members(crew: &KapyCrew): &VecSet<u8> {
    &crew.members
}

public fun strength(crew: &KapyCrew): u16 {
    crew.strength
}

public fun found_treasure(crew: &KapyCrew): bool {
    crew.found_treasure
}

// Internal Funs

fun get_strength(members: VecSet<u8>): u16 {
    members.into_keys().fold!(
        0, |strength, kind| (strength as u16) + (pow(2, kind) as u16)
    )
}

fun build_crew_internal(
    world: &mut KapyWorld,
    name: String,
    ctx: &mut TxContext,
): KapyCrew {
    world.add_crew();
    let id = object::new(ctx);
    let index = world.crew_supply();
    events::emit_new_crew(id.to_inner(), index);
    KapyCrew {
        id,
        index,
        name,
        members: vec_set::empty(),
        strength: 0,
        found_treasure: false,
    }
}

//  Test-only Funs

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    use sui::test_utils;
    init(test_utils::create_one_time_witness<KAPY_CREW>(), ctx);
}
