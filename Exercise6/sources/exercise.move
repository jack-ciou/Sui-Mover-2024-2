module exercise::exercise {
    use mover_nft::mover_nft::Tails;
    use lesson_5::simple_nft::SimpleNFT;

    use kapy_adventure::kapy_world::KapyWorld;
    use kapy_adventure::kapy_crew::KapyCrew;
    use kapy_adventure::kapy_pirate;

    const PIRATE_KIND: u8 = 3;

    public struct NFT_EXERCISE has drop {}

    public fun goal(
        world: &KapyWorld,
        crew: &mut KapyCrew,
        _simple_nft: &SimpleNFT,
        _tails: &Tails,
        ctx: &mut TxContext
    ) {
        let pirate = kapy_pirate::new(
        world,
        PIRATE_KIND,
            NFT_EXERCISE {},
        ctx,
        );
        crew.recruit(pirate);
    }

    public fun goal_2(
        world: &KapyWorld,
        crew: &mut KapyCrew,
        _simple_nft: &SimpleNFT,
        tails: Tails,
        ctx: &mut TxContext
    ): Tails {
        let pirate = kapy_pirate::new(
        world,
        PIRATE_KIND,
            NFT_EXERCISE {},
        ctx,
        );
        crew.recruit(pirate);
        tails
    }
}
