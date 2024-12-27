module exercise_2::pickaxe;

// Dependencies

use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use kapy_adventure::kapy_world::{GodPower};

// Constants

const BASE_PRICE: u64 = 10;

// Errors

const EPaymentNotEnough: u64 = 0;
fun err_payment_not_enough() { abort EPaymentNotEnough }

// Objects

public struct Pickaxe has key, store {
    id: UID,
    tier: u8,
}

public struct PickaxeStore has key {
    id: UID,
    treasury: Balance<SUI>,
}

// invariant

fun init(ctx: &mut TxContext) {
    let store = PickaxeStore {
        id: object::new(ctx),
        treasury: balance::zero(),
    };
    transfer::share_object(store);
}

// Public Funs

public fun buy(
    store: &mut PickaxeStore,
    tier: u8,
    payment: Coin<SUI>,
    ctx: &mut TxContext,
): Pickaxe {
    if (payment.value() < (tier as u64) * base_price()) {
        err_payment_not_enough();
    };

    coin::put(&mut store.treasury, payment);
    Pickaxe {
        id: object::new(ctx),
        tier,
    }
}

entry fun buy_and_transfer(
    store: &mut PickaxeStore,
    tier: u8,
    payment: Coin<SUI>,
    recipient: address,
    ctx: &mut TxContext,
) {
    let pickaxe = store.buy(tier, payment, ctx);
    transfer::transfer(pickaxe, recipient);
}

public fun destroy(pickaxe: Pickaxe): u8 {
    let Pickaxe { id, tier } = pickaxe;
    id.delete();
    tier
}

public fun withdraw(
    store: &mut PickaxeStore,
    _power: &GodPower,
    value: u64,
    ctx: &mut TxContext,
): Coin<SUI> {
    store.treasury.split(value).into_coin(ctx)
}

entry fun withdraw_to(
    store: &mut PickaxeStore,
    power: &GodPower,
    value: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let fund = store.withdraw(power, value, ctx);
    transfer::public_transfer(fund, recipient);
}

// Getter Funs

public fun base_price(): u64 { BASE_PRICE }

public fun tier(pickaxe: &Pickaxe): u8 {
    pickaxe.tier
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}
