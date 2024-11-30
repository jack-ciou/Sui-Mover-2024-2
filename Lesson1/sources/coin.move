module lesson_1::coin;

public struct Coin<phantom T> has key, store {
    id: UID,
    value: u64,
}

public fun value<T>(self: &Coin<T>): u64 {
    self.value
}

public fun join<T>(
    self: &mut Coin<T>,
    c: Coin<T>,
) {
    let Coin { id, value } = c;
    id.delete();
    self.value = self.value() + value;
}

public fun split<T>(
    self: &mut Coin<T>,
    split_amount: u64,
    ctx: &mut TxContext,
): Coin<T> {
    assert!(self.value() >= split_amount);
    self.value = self.value() - split_amount;
    Coin {
        id: object::new(ctx),
        value: split_amount,
    }
}

public fun zero<T>(ctx: &mut TxContext): Coin<T> {
    Coin { id: object::new(ctx), value: 0 }
}

entry fun transfer_zero<T>(ctx: &mut TxContext) {
    let coin = zero<T>(ctx);
    transfer::transfer(coin, @0x123);
}

public fun destroy_zero<T>(self: Coin<T>) {
    let Coin { id, value } = self;
    assert!(value == 0);
    id.delete();
}
