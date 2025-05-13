module dice::dice;

use sui::vec_set::{Self, VecSet};
use sui::random::{ Self, Random};

public struct Dice has key {
    id: UID,
    values: VecSet<u8>,
    current_value: u8,
}

fun init(ctx: &mut TxContext){

    let mut values = vec_set::empty();
    values.insert(1);
    values.insert(2);
    values.insert(3);
    values.insert(4);
    values.insert(5);
    values.insert(6);

    let dice =  Dice{
        id: object::new(ctx),
        values,
        current_value: 1
    };
    
    transfer::share_object(dice);
}

entry fun roll(self: &mut Dice, rand: &Random, ctx: &mut TxContext){
    let mut generator = random::new_generator(rand, ctx);
    let random_num = random::generate_u8_in_range(&mut generator, 0, 5);
    self.current_value = *self.values.keys().borrow(random_num as u64);
}
