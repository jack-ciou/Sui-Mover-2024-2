#[test_only]
module giveaway::giveaway_tests;
// uncomment this line to import the module
use giveaway::giveaway;
use sui::test_scenario::{Self as ts};
use sui::coin;
use sui::sui::SUI;


#[test]
fun test_giveaway() {
    let creator = @0x1;
    let mut scenario_val = ts::begin(creator);
    let scenario = &mut scenario_val;
    {
        giveaway::test_init(scenario.ctx());
    };
    ts::next_tx(scenario, creator);
    {
        let deposit = coin::mint_for_testing<SUI>(1000, scenario.ctx());
        let public_key = x"0367e07b8ee144cac65c51ad5714e4fd33a0d32e2806dde71c82583baaa37cc0";
        let mut manager = scenario.take_shared<giveaway::GiftManager>();
        giveaway::create_gift(
            &mut manager,
            deposit,
            public_key,
            scenario.ctx()
        );
        ts::return_shared(manager);
    };
    ts::next_tx(scenario, creator);
    {
        let public_key = x"0367e07b8ee144cac65c51ad5714e4fd33a0d32e2806dde71c82583baaa37cc0";
        let signature = x"cc70d9a2b0d0d1be08b628ee4f745ff2d856f7fc452a755c80a8582db6a33c728bca8327da8b226a6c802be229e969bcb65f4a9191a55cc8cf64cafc7947e90b";
        let recipient = @0x96d9a120058197fce04afcffa264f2f46747881ba78a91beb38f103c60e315ae;
        let mut manager = scenario.take_shared<giveaway::GiftManager>();
        giveaway::withdraw_gift<SUI>(
            &mut manager,
            recipient,
            signature,
            public_key,
            scenario.ctx()
        );
        ts::return_shared(manager);
    };
    ts::end(scenario_val);
}

#[test]
#[expected_failure(abort_code = 0, location = giveaway)]
fun test_giveaway_invalid_signature() {
    let creator = @0x1;
    let mut scenario_val = ts::begin(creator);
    let scenario = &mut scenario_val;
    {
        giveaway::test_init(scenario.ctx());
    };
    ts::next_tx(scenario, creator);
    {
        let deposit = coin::mint_for_testing<SUI>(1000, scenario.ctx());
        let public_key = x"0367e07b8ee144cac65c51ad5714e4fd33a0d32e2806dde71c82583baaa37cc0";
        let mut manager = scenario.take_shared<giveaway::GiftManager>();
        giveaway::create_gift(
            &mut manager,
            deposit,
            public_key,
            scenario.ctx()
        );
        ts::return_shared(manager);
    };
    ts::next_tx(scenario, creator);
    {
        let public_key = x"0367e07b8ee144cac65c51ad5714e4fd33a0d32e2806dde71c82583baaa37cc0";
        let signature = x"";
        let recipient = @0x96d9a120058197fce04afcffa264f2f46747881ba78a91beb38f103c60e315ae;
        let mut manager = scenario.take_shared<giveaway::GiftManager>();
        giveaway::withdraw_gift<SUI>(
            &mut manager,
            recipient,
            signature,
            public_key,
            scenario.ctx()
        );
        ts::return_shared(manager);
    };
    ts::end(scenario_val);
}