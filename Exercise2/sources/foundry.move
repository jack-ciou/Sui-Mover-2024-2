module exercise_2::foundry;

// Dependencies

use exercise_2::mine::{Self, Ore};

// Constants

const ORE_QUALITY_THESHOLD: u8 = 20;

// Errors

const EOreNotQualified: u64 = 0;
fun err_ore_not_qualified() { abort EOreNotQualified }

// Objects

public struct Sword has key, store {
    id: UID,
    level: u8,
}

// Public Funs

public fun forge(ore: Ore, ctx: &mut TxContext): Sword {
    let quality = mine::melt(ore);
    if (quality < quality_threshold()) {
        err_ore_not_qualified();
    };
    
    Sword {
        id: object::new(ctx),
        level: quality / 2,
    }
}

entry fun forge_and_transfer(
    ore: Ore,
    recipient: address,
    ctx: &mut TxContext,
) {
    let sword = forge(ore, ctx);
    transfer::transfer(sword, recipient);
}

// Getter Funs

public fun quality_threshold(): u8 {
    ORE_QUALITY_THESHOLD
}

public fun level(sword: &Sword): u8 {
    sword.level
}
