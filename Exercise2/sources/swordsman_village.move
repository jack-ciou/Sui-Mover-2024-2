module exercise_2::swordsman_village;

// Dependencies

use kapy_adventure::kapy_world::KapyWorld;
use kapy_adventure::kapy_crew::KapyCrew;
use kapy_adventure::kapy_pirate;
use exercise_2::foundry::Sword;

// Constants

const PIRATE_KIND: u8 = 1;

// Witness

public struct SwordsmanVillage has drop {}

// Public Funs

public fun recurit(
    world: &KapyWorld,
    crew: &mut KapyCrew,
    sword: Sword,
    ctx: &mut TxContext,
) {
    // crew a pirate (kind: 1)
    let pirate = kapy_pirate::new(
        world,
        pirate_kind(),
        SwordsmanVillage {},
        ctx,
    );

    // give the sword to the pirate
    let pirate_address = object::id(&pirate).to_address();
    transfer::public_transfer(sword, pirate_address);

    // recruit the swordsman pirate
    crew.recruit(pirate);
}

// Getter Funs

public fun pirate_kind(): u8 { PIRATE_KIND }
