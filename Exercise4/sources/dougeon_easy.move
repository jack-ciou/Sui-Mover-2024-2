module exercise_4::dougeon_easy {
    use sui::table::{Self, Table};

    use kapy_adventure::kapy_world::KapyWorld;
    use kapy_adventure::kapy_crew::KapyCrew;
    use kapy_adventure::kapy_pirate;

    // ====== Constants ======
    const PIRATE_KIND: u8 = 2;
    const MIN_X: u64 = 0;
    const MAX_X: u64 = 7;
    const MIN_Y: u64 = 0;
    const MAX_Y: u64 = 7;
    const WALL: vector<vector<u64>> = vector[
        vector[0, 1], vector[0, 2], vector[0, 5], vector[1, 5],
        vector[3, 0], vector[3, 5], vector[3, 6], vector[3, 7],
        vector[4, 2], vector[4, 3], vector[4, 4], vector[4, 5],
        vector[5, 6], vector[6, 3], vector[6, 6], vector[7, 3]
    ];
    const TREASURE_BOX: vector<u64> = vector[4, 6];
    const MONSTER: vector<vector<u64>> = vector[
        vector[0, 6], vector[3, 3], vector[5, 1], vector[5, 5]
    ];

    // ====== Errors ======
    const EInvalidStep: u64 = 0;
    const EInvalidStatus: u64 = 1;
    const EInvalidTargetLocation: u64 = 2;
    const ENoTreasureBox: u64 = 3;

    // ====== Structs ======
    public struct Dougeon has key, store {
        id: UID,
        status: Table<address, PlayerStatus>,
        location: Table<address, Location>
    }

    public struct PlayerStatus has store {
        status: u64 // 0: normal, 1: dead, 2: clear
    }

    public struct Location has store {
        x: u64,
        y: u64
    }

    // Witness
    public struct DougeonEasy has drop {}

    fun init(ctx: &mut TxContext) {
        let dougeon = Dougeon {
            id: object::new(ctx),
            status: table::new(ctx),
            location: table::new(ctx),
        };
        transfer::share_object(dougeon);
    }

    entry fun walk(
        dougeon: &mut Dougeon,
        horizon: bool, // true => x, false => y
        forward: bool, // true => +, false => -
        steps: u64,
        ctx: &TxContext
    ) {
        assert!(steps > 0, invalid_step());

        let player = tx_context::sender(ctx);
        create_player(dougeon, player);

        let player_status = dougeon.status.borrow_mut(player);
        assert!(player_status.status == 0, invalid_status());

        let location = dougeon.location.borrow_mut(player);
        if (horizon) {
            if (forward) {
                assert!(location.x + steps <= MAX_X, invalid_target_location());
            } else {
                assert!(steps <= location.x && location.x - steps >= MIN_X, invalid_target_location());
            };
        } else {
            if (forward) {
                assert!(location.y + steps <= MAX_Y, invalid_target_location());
            } else {
                assert!(steps <= location.y && location.y - steps >= MIN_Y, invalid_target_location());
            };
        };
        walk_(player_status, location, horizon, forward, steps);
    }

    entry fun goal(
        dougeon: &mut Dougeon,
        world: &KapyWorld,
        crew: &mut KapyCrew,
        ctx: &mut TxContext
    ) {
        let player = tx_context::sender(ctx);
        let player_status = dougeon.status.borrow_mut(player);
        assert!(player_status.status == 0, invalid_status());

        let location = dougeon.location.borrow_mut(player);
        let treasure_box = TREASURE_BOX;
        assert!(location.x == treasure_box[0] && location.y == treasure_box[1], no_treasure_box());
        let pirate = kapy_pirate::new(
        world,
        pirate_kind(),
            DougeonEasy {},
        ctx,
        );
        crew.recruit(pirate);
        player_status.status = 2;
    }

    entry fun restart(dougeon: &mut Dougeon, ctx: &TxContext) {
        let player = tx_context::sender(ctx);
        let player_status = dougeon.status.borrow_mut(player);
        assert!(player_status.status == 1, invalid_status());
        player_status.status = 0;

        let location = dougeon.location.borrow_mut(player);
        location.x = 0;
        location.y = 0;
    }

    fun walk_(
        player_status: &mut PlayerStatus,
        location: &mut Location,
        horizon: bool, // true => x, false => y
        forward: bool, // true => +, false => -
        mut steps: u64,
    ) {
        while (steps > 0) {
            let (new_x, new_y) = if (horizon) {
                let new_x = if (forward) { location.x + 1 } else { location.x - 1 };
                (new_x, location.y)
            } else {
                let new_y = if (forward) { location.y + 1 } else { location.y - 1 };
                (location.x, new_y)
            };
            // check wall (hit the wall => stay at previous location)
            if (check_wall(new_x, new_y)) {
                break
            };

            // check monster (encounter => dead & move to monster location)
            let encounter_monster = check_encountering_monster(player_status, new_x, new_y);

            // update location
            location.x = new_x;
            location.y = new_y;

            // encounter_monster => dead => early return
            if (encounter_monster) {
                break
            };

            steps = steps - 1;
        };
    }

    public fun get_player_info(dougeon: &Dougeon, player: address): vector<u64> {
        if (!dougeon.status.contains(player)) {
            vector[]
        } else {
            vector[
                dougeon.status.borrow(player).status,
                dougeon.location.borrow(player).x,
                dougeon.location.borrow(player).y,
            ]
        }
    }

    public fun pirate_kind(): u8 { PIRATE_KIND }

    fun create_player(dougeon: &mut Dougeon, player: address) {
        if (!dougeon.status.contains(player)) {
            dougeon.status.add(player, PlayerStatus { status: 0 });
            dougeon.location.add(player, Location { x: 0, y: 0 });
        }
    }

    fun check_wall(x: u64, y: u64): bool {
        let current_location = vector[x, y];
        let wall = WALL;
        wall.contains(&current_location)
    }

    fun check_encountering_monster(player_status: &mut PlayerStatus, x: u64, y: u64): bool {
        let current_location = vector[x, y];
        let monster = MONSTER;
        let encounter_monster = monster.contains(&current_location);
        if (encounter_monster) {
            player_status.status = 1; // player dead
        };
        encounter_monster
    }

    fun invalid_step(): u64 { abort EInvalidStep }
    fun invalid_status(): u64 { abort EInvalidStatus }
    fun invalid_target_location(): u64 { abort EInvalidTargetLocation }
    fun no_treasure_box(): u64 { abort ENoTreasureBox }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}
