module lesson_5::mover_nft {

    use std::string::{Self, String};

    use sui::url::{Self, Url};
    use sui::display;
    use sui::vec_map::{Self, VecMap};
    use sui::event;
    use sui::table_vec::{Self, TableVec};
    use sui::random::{Self, Random};

    const E_INVALID_WHITELIST: u64 = 1;
    const E_EMPTY_POOL: u64 = 2;
    const E_NOT_LIVE: u64 = 3;

    public struct Tails has key, store {
        id: UID,
        name: String,
        description: String,
        number: u64,
        url: Url, // ibafybeiaotsmbrfvn3u3xiobrxlrzbhffnlqyui5sweohjbd3l2bhyvndpm
        attributes: VecMap<String, String>,
    }

    /// One time witness is only instantiated in the init method
    public struct MOVER_NFT has drop {}

    public struct ManagerCap has key, store { id: UID }

    #[lint_allow(self_transfer, share_owned)]
    fun init(otw: MOVER_NFT, ctx: &mut TxContext) {
        let publisher = sui::package::claim(otw, ctx);

        let mut display = display::new<Tails>(&publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"{url}")); // ipfs://ibafybeiaotsmbrfvn3u3xiobrxlrzbhffnlqyui5sweohjbd3l2bhyvndpm
        display::add(&mut display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut display);

        let manager_cap = ManagerCap { id: object::new(ctx) };

        let sender = tx_context::sender(ctx);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(display, sender);
        transfer::public_transfer(manager_cap, sender);
    }

    public struct Pool has key {
        id: UID,
        tails: TableVec<Tails>,
        num: u64,
        is_live: bool,
        // price: u64,
        // start_time: u64,
    }

    entry fun new_pool(
        _manager_cap: &ManagerCap,
        ctx: &mut TxContext,
    ) {
        let pool = Pool {
            id: object::new(ctx),
            tails: table_vec::empty(ctx),
            num: 0,
            is_live: false,
        };
        transfer::share_object(pool);
    }

    entry fun close_pool(
        _manager_cap: &ManagerCap,
        pool: Pool,
    ) {
        let Pool {
            id,
            tails,
            num:_,
            is_live:_,
        } = pool;

        table_vec::destroy_empty(tails);
        object::delete(id);
    }

    public struct NewManagerCapEvent has copy, drop {
        id: ID,
        sender: address
    }

    #[lint_allow(self_transfer)]
    entry fun new_manager_cap (
        _manager_cap: &ManagerCap,
        ctx: &mut TxContext,
    ) {
        let manager_cap = ManagerCap { id: object::new(ctx) };
        let sender = tx_context::sender(ctx);

        let new_manager_cap_event = NewManagerCapEvent {
            id: object::id(&manager_cap),
            sender
        };
        event::emit(new_manager_cap_event);

        transfer::public_transfer(manager_cap, sender);
    }

    entry fun deposit_nft(
        _manager_cap: &ManagerCap,
        pool: &mut Pool,
        name: String,
        number: u64,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        ctx: &mut TxContext,
    ) {
        let nft = Tails {
            id: object::new(ctx),
            name,
            number,
            description: string::utf8(b"Tails by Sui Mover 2024."),
            url: url::new_unsafe_from_bytes(url),
            attributes: vec_map::from_keys_values(attribute_keys, attribute_values)
        };

        table_vec::push_back(&mut pool.tails, nft);
        pool.num = pool.num + 1;
    }

    public struct Whitelist has key {
        id: UID,
        pool_id: ID
    }

    entry fun issue_whitelist(
        _manager_cap: &ManagerCap,
        pool: &Pool,
        mut recipients: vector<address>,
        ctx: &mut TxContext,
    ) {
        while (!vector::is_empty(&recipients)) {
            let recipient = vector::pop_back<address>(&mut recipients);
            let id = object::id(pool);
            let wl = Whitelist{ id: object::new(ctx), pool_id: id };
            transfer::transfer(wl, recipient);
        }
    }

    entry fun update_sale(
        _manager_cap: &ManagerCap,
        pool: &mut Pool,
        is_live: bool,
    ) {
        pool.is_live = is_live;
    }

    public(package) fun withdraw_nfts(
        _manager_cap: &ManagerCap,
        pool: &mut Pool,
        mut n: u64
    ): vector<Tails> {
        let mut nfts = vector::empty<Tails>();
        while (n > 0) {
            let nft = table_vec::pop_back(&mut pool.tails);
            vector::push_back(&mut nfts, nft);
            n = n - 1;
        };
        nfts
    }

    // Staking Related
    public fun update_image_url(
        _manager_cap: &ManagerCap,
        tails: &mut Tails,
        url: vector<u8>,
    ) {
        tails.url = url::new_unsafe_from_bytes(url);
    }

    // User Entry
    public struct MintEvent has copy, drop {
        id: ID,
        name: String,
        description: String,
        number: u64,
        url: Url,
        attributes: VecMap<String, String>,
        sender: address
    }

    public(package) fun emit_mint_event(nft: &Tails, sender: address) {
        let mint_event = MintEvent {
            id: object::id(nft),
            name: nft.name,
            description: nft.description,
            number: nft.number,
            url: nft.url,
            attributes: nft.attributes,
            sender
        };
        event::emit(mint_event);
    }

    entry fun free_mint(
        pool: &mut Pool,
        whitelist_token: Whitelist,
        random: &Random, // 0x8
        ctx: &mut TxContext,
    ) {
        assert!(pool.is_live, E_NOT_LIVE);
        let len = table_vec::length(&pool.tails);
        assert!(len > 0, E_EMPTY_POOL);
        let Whitelist {id, pool_id} = whitelist_token;
        object::delete(id);
        assert!(pool_id == object::id(pool), E_INVALID_WHITELIST);

        let nft = if (len == 1) {
            table_vec::pop_back(&mut pool.tails)
        } else {
            let mut generator = random::new_generator(random, ctx);
            let i = random::generate_u64_in_range(&mut generator, 0, len-1);
            table_vec::swap_remove(&mut pool.tails, i)
        };

        let mint_event = MintEvent {
            id: object::id(&nft),
            name: nft.name,
            description: nft.description,
            number: nft.number,
            url: nft.url,
            attributes: nft.attributes,
            sender: tx_context::sender(ctx)
        };
        event::emit(mint_event);
        transfer::public_transfer(nft, ctx.sender());
    }

    // Public Functions

    public fun tails_number(
        nft: &Tails,
    ): u64 {
        nft.number
    }

    public fun tails_attributes(
        nft: &Tails,
    ): VecMap<String, String> {
        nft.attributes
    }
}
