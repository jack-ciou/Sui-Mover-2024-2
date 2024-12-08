#[test_only]
module lesson_4::lesson_4_tests {
    use sui::test_scenario::{Self, Scenario, ctx, sender, next_tx, take_shared, return_shared, end};
    use lesson_4::lesson_4::{Self, Dougeon};

    const ADMIN: address = @0xBBB;

    // ====== Helper functions ======

    fun scenario(): Scenario {
        let mut scenario = test_scenario::begin(ADMIN);
        lesson_4::test_init(ctx(&mut scenario));
        next_tx(&mut scenario, ADMIN);
        scenario
    }

    fun dougeon(scenario: &Scenario): Dougeon {
        take_shared<Dougeon>(scenario)
    }

    fun test_walk(scenario: &mut Scenario, horizon: bool, forward: bool, steps: u64) {
        let mut dougeon = dougeon(scenario);
        lesson_4::walk(&mut dougeon, horizon, forward, steps, ctx(scenario));
        return_shared(dougeon);
        next_tx(scenario, ADMIN);
    }

    fun test_retart(scenario: &mut Scenario) {
        let mut dougeon = dougeon(scenario);
        lesson_4::restart(&mut dougeon, ctx(scenario));
        return_shared(dougeon);
        next_tx(scenario, ADMIN);
    }

    fun test_get_player_info(scenario: &mut Scenario): vector<u64> {
        let dougeon = dougeon(scenario);
        let player_info = lesson_4::get_player_info(&dougeon, sender(scenario));
        return_shared(dougeon);
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
    #[expected_failure(abort_code = lesson_4::EInvalidStatus)]
    fun test_restart_failed() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 2);
        test_retart(&mut scenario);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = lesson_4::EInvalidTargetLocation)]
    fun test_out_of_bound_error() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 8);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = lesson_4::EInvalidTargetLocation)]
    fun test_out_of_bound_error_2() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, false, 1);
        end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = lesson_4::EInvalidStep)]
    fun test_zero_step_error() {
        let mut scenario = scenario();
        test_walk(&mut scenario, true, true, 0);
        end(scenario);
    }
}
