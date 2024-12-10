#[test_only]
module exercise_2::exercise_2_tests;

use std::string::utf8;
use sui::test_scenario::{Self as ts, Scenario};
use sui::coin;
use exercise_2::pickaxe::{Self, PickaxeStore};
use exercise_2::mine::{Self, Mine};
use exercise_2::foundry;
use exercise_2::swordsman_village::{Self, SwordsmanVillage};
use kapy_adventure::kapy_world::{Self, KapyWorld, GodPower};
use kapy_adventure::kapy_crew::{Self, KapyCrew};

#[test]
fun test_exercise_2() {
    let god = @0x777;
    let player = @0x111;

    // setup
    let mut scenario = ts::begin(god);
    let s = &mut scenario;
    kapy_world::init_for_testing(s.ctx());
    kapy_crew::init_for_testing(s.ctx());
    pickaxe::init_for_testing(s.ctx());
    mine::init_for_testing(s.ctx());
    
    // God add pirate rule (kind: 1) and build crew for player
    s.next_tx(god);
    let power = s.take_from_sender<GodPower>();
    let mut world = s.take_shared<KapyWorld>();
    world.add_pirate_rule<SwordsmanVillage>(
        &power,
        swordsman_village::pirate_kind(),
    );
    let name = utf8(b"Justa");
    let crew = kapy_crew::build_crew_by_god(&mut world, &power, name, s.ctx());
    transfer::public_transfer(crew, player);
    s.return_to_sender(power);
    ts::return_shared(world);

    // solve exercise 2
    s.next_tx(player);
    let world = s.take_shared<KapyWorld>();
    let mut crew = s.take_from_sender<KapyCrew>();
    let mut store = s.take_shared<PickaxeStore>();
    let mut mines = take_mines(s);
    let tier = 200;
    let payment_amount = tier * pickaxe::base_price();
    let payment = coin::mint_for_testing(payment_amount, s.ctx());

    let pickaxe = store.buy((tier as u8), payment, s.ctx());
    mines.do_mut!(|mine| {
        if (crew.index() % mine::num_of_mines() == mine.index()) {
            let ore = mine.exploit(&crew, &pickaxe, s.ctx());
            let sword = foundry::forge(ore, s.ctx());
            swordsman_village::recurit(&world, &mut crew, sword, s.ctx());
        };
    });
    pickaxe.destroy();
    assert!(crew.strength() == 2);
    assert!(crew.members().contains(&swordsman_village::pirate_kind()));
    ts::return_shared(world);
    s.return_to_sender(crew);
    ts::return_shared(store);
    return_mines(mines);

    scenario.end();
}

public fun take_mines(s: &mut Scenario): vector<Mine> {
    let mut mines = vector<Mine>[];
    while (ts::has_most_recent_shared<Mine>()) {
        let mine = s.take_shared<Mine>();
        mines.push_back(mine);
    };
    mines
}

public fun return_mines(mines: vector<Mine>) {
    mines.destroy!(|mine| ts::return_shared(mine));
} 
