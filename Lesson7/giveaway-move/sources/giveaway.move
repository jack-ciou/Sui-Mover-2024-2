module giveaway::giveaway {
    use sui::balance::Balance;
    use sui::object_bag::{Self, ObjectBag};
    use sui::coin::{Self, Coin};
    use sui::ed25519::{ ed25519_verify };

    const EInvalidSignature: u64 = 0;

    public struct Gift<phantom T> has key, store {
        id: UID,
        public_key: vector<u8>,
        value: Balance<T>,
    }

    public struct GiftManager has key, store {
        id: UID,
        gifts: ObjectBag,
    }

    fun init(ctx: &mut TxContext) {
        let manager = GiftManager {
            id: object::new(ctx),
            gifts: object_bag::new(ctx),
        };
        transfer::share_object(manager);
    }

    public fun create_gift<T>(
        manager: &mut GiftManager,
        deposit: Coin<T>,
        public_key: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let gift = Gift {
            id: object::new(ctx),
            public_key,
            value: deposit.into_balance(),
        };
        manager.gifts.add(public_key, gift);
    }

    public fun withdraw_gift<T>(
        manager: &mut GiftManager,
        recipient: address,
        signature: vector<u8>,
        public_key: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let message = recipient.to_bytes();
        let is_valid = ed25519_verify(&signature, &public_key, &message);
        assert!(is_valid, EInvalidSignature);
        let gift = manager.gifts.remove<vector<u8>, Gift<T>>(public_key);
        let Gift {id, public_key: _, value,} = gift;
        object::delete(id);
        transfer::public_transfer(
            coin::from_balance(value, ctx),
            recipient
        );
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}
