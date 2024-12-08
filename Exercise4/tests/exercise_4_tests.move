#[test_only]
module exercise_4::exercise_4_tests {
    use sui::test_scenario::{Self, Scenario, ctx, sender, next_tx, take_shared, return_shared, take_from_address, return_to_address, end};
    use exercise_4::dougeon_easy::{Self, Dougeon, DougeonEasy};

    use kapy_adventure::kapy_crew;
    use kapy_adventure::kapy_world::{Self, KapyWorld, GodPower};

    const ADMIN: address = @0xBBB;

    // ====== Helper functions ======

    fun scenario(): Scenario {
        let mut scenario = test_scenario::begin(ADMIN);
        dougeon_easy::test_init(ctx(&mut scenario));
        next_tx(&mut scenario, ADMIN);
        scenario
    }

    fun dougeon_easy(scenario: &Scenario): Dougeon {
        take_shared<Dougeon>(scenario)
    }

    fun test_walk(scenario: &mut Scenario, horizon: bool, forward: bool, steps: u64) {
        let mut dougeon_easy = dougeon_easy(scenario);
        dougeon_easy::walk(&mut dougeon_easy, horizon, forward, steps, ctx(scenario));
        return_shared(dougeon_easy);
        next_tx(scenario, ADMIN);
    }

    fun test_goal(scenario: &mut Scenario) {
        let mut dougeon_easy = dougeon_easy(scenario);

        kapy_world::init_for_testing(ctx(scenario));
        next_tx(scenario, ADMIN);
        kapy_crew::init_for_testing(ctx(scenario));
        next_tx(scenario, ADMIN);
        let mut world = take_shared<KapyWorld>(scenario);
        let god_power = take_from_address<GodPower>(scenario, sender(scenario));
        kapy_world::add_pirate_rule<DougeonEasy>(&mut world, &god_power, dougeon_easy::pirate_kind());
        next_tx(scenario, ADMIN);

        let mut crew = kapy_crew::build_crew_by_god(
            &mut world,
            &god_power,
            std::string::utf8(b"Exercise4"),
            ctx(scenario),
        );

        dougeon_easy::goal(&mut dougeon_easy, &world, &mut crew, ctx(scenario));

        return_shared(world);
        return_to_address(sender(scenario), god_power);

        transfer::public_transfer(crew, sender(scenario));

        return_shared(dougeon_easy);
        next_tx(scenario, ADMIN);
    }

    fun test_retart(scenario: &mut Scenario) {
        let mut dougeon_easy = dougeon_easy(scenario);
        dougeon_easy::restart(&mut dougeon_easy, ctx(scenario));
        return_shared(dougeon_easy);
        next_tx(scenario, ADMIN);
    }

    fun test_well_done_(scenario: &mut Scenario) {
        test_walk(scenario, true, true, 2);
        test_walk(scenario, false, true, 1);
        test_walk(scenario, true, true, 2);
        test_walk(scenario, false, false, 1);
        test_walk(scenario, true, true, 2);
        test_walk(scenario, false, true, 2);
        test_walk(scenario, true, false, 1);
        test_walk(scenario, false, true, 2);
        test_walk(scenario, true, true, 2);
        test_walk(scenario, false, true, 3);
        test_walk(scenario, true, false, 3);
        test_walk(scenario, false, false, 1);
        test_goal(scenario);
        next_tx(scenario, ADMIN);
    }

    fun test_get_player_info(scenario: &mut Scenario): vector<u64> {
        let dougeon_easy = dougeon_easy(scenario);
        let player_info = dougeon_easy::get_player_info(&dougeon_easy, sender(scenario));
        return_shared(dougeon_easy);
        next_tx(scenario, ADMIN);
        player_info
    }

    // ====== Scenarios ======

    #[test]
    fun test_move_forward() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 1);
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 0, 0);
        assert!(player_info[1] == 1, 0);
        assert!(player_info[2] == 0, 0);
        std::debug::print(&player_info);
        end(scenario);
    }

    #[test]
    fun test_move_backward() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 1);
        test_walk(&mut scenario, true, false, 1);
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 0, 0);
        assert!(player_info[1] == 0, 0);
        assert!(player_info[2] == 0, 0);
        std::debug::print(&player_info);
        end(scenario);
    }

    #[test]
    fun test_hit_the_wall() {
        let mut scenario = scenario();
        test_walk(&mut scenario, false, true, 1);
        let player_info = test_get_player_info(&mut scenario);
        // stay at previous location
        assert!(player_info[0] == 0, 0);
        assert!(player_info[1] == 0, 0);
        assert!(player_info[2] == 0, 0);
        std::debug::print(&player_info);

        test_walk(&mut scenario, false, true, 5);
        // stay at previous location
        assert!(player_info[0] == 0, 0);
        assert!(player_info[1] == 0, 0);
        assert!(player_info[2] == 0, 0);
        std::debug::print(&player_info);
        end(scenario);
    }

    #[test]
    fun test_encounter_monster() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 2);
        test_walk(&mut scenario, false, true, 3);
        test_walk(&mut scenario, true, true, 1);
        // stay at previous location
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 1, 0);
        assert!(player_info[1] == 3, 0);
        assert!(player_info[2] == 3, 0);
        std::debug::print(&player_info);

        test_retart(&mut scenario);
        // restarted
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 0, 0);
        assert!(player_info[1] == 0, 0);
        assert!(player_info[2] == 0, 0);
        std::debug::print(&player_info);

        end(scenario);
    }

    #[test]
    fun test_well_done() {
        let mut scenario = scenario();
        test_well_done_(&mut scenario);
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 2, 0);
        assert!(player_info[1] == 4, 0);
        assert!(player_info[2] == 6, 0);
        std::debug::print(&player_info);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidStatus)]
    fun test_restart_failed() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 2);
        test_retart(&mut scenario);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidStatus)]
    fun test_restart_failed_after_clear() {
        let mut scenario = scenario();
        test_well_done_(&mut scenario);
        test_retart(&mut scenario);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidStatus)]
    fun test_dead_player_walked() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 2);
        test_walk(&mut scenario, false, true, 3);
        test_walk(&mut scenario, true, true, 1);
        // stay at previous location
        let player_info = test_get_player_info(&mut scenario);
        assert!(player_info[0] == 1, 0);
        assert!(player_info[1] == 3, 0);
        assert!(player_info[2] == 3, 0);

        test_walk(&mut scenario, true, true, 2);

        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidTargetLocation)]
    fun test_out_of_bound_error() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 8);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidTargetLocation)]
    fun test_out_of_bound_error_2() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, false, 1);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = dougeon_easy::EInvalidStep)]
    fun test_zero_step_error() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 0);
        end(scenario);
    }
}
