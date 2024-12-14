module exercise_2::mine;

// Dependencies

use kapy_adventure::kapy_crew::KapyCrew;
use exercise_2::pickaxe::Pickaxe;

// Constants

const NUM_OF_MINES: u32 = 5;

// Errors

const ENotAllowedToExploitThisMine: u64 = 0;
fun err_not_allowed_to_exploit_this_mine() { abort ENotAllowedToExploitThisMine }

// Objects

public struct Mine has key {
    id: UID,
    index: u32,
}

public struct Ore has key, store {
    id: UID,
    quality: u8,
}

// Init

fun init(ctx: &mut TxContext) {
    std::u32::do!(num_of_mines(), |index| {
        let mine = Mine {
            id: object::new(ctx),
            index,
        };
        transfer::share_object(mine);
    });
}

// Public Funs

public fun exploit(
    mine: &mut Mine,
    crew: &KapyCrew,
    pickaxe: &Pickaxe,
    ctx: &mut TxContext,
): Ore {
    if (crew.index() % num_of_mines() != mine.index()) {
        err_not_allowed_to_exploit_this_mine();
    };
    
    let id = object::new(ctx);
    let range = ((pickaxe.tier() / 3) as u256);
    let quality = if (range > 0) {
        let offset = ((pickaxe.tier() / 2) as u256);
        let quality = offset + id.to_address().to_u256() % range;
        (quality as u8)
    } else {
        0
    };
    Ore { id, quality }
}

entry fun exploit_and_transfer(
    mine: &mut Mine,
    crew: &KapyCrew,
    pickaxe: &Pickaxe,
    recipient: address,
    ctx: &mut TxContext,
) {
    let ore = mine.exploit(crew, pickaxe, ctx);
    transfer::transfer(ore, recipient);
}

// Package Funs

public(package) fun melt(ore: Ore): u8 {
    let Ore { id, quality } = ore;
    id.delete();
    quality
}

// Getter Funs

public fun num_of_mines(): u32 {
    NUM_OF_MINES
}

public fun index(mine: &Mine): u32 {
    mine.index
}

// Test-only Funs

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}
