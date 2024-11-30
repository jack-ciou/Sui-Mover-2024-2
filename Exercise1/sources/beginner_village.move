module exercise_1::beginner_village;

// Dependencies

use kapy_adventure::kapy_world::KapyWorld;
use kapy_adventure::kapy_crew::KapyCrew;
use kapy_adventure::kapy_pirate;
use std::string::String;

// Constants

const PIRATE_KIND: u8 = 0;
const MIN_NAME_LENGTH: u64 = 3;
const MAX_NAME_LENGTH: u64 = 16;

// Errors

const ENameTooShort: u64 = 1;
fun err_name_too_short() { abort ENameTooShort }

const ENameTooLong: u64 = 2;
fun err_name_too_long() { abort ENameTooLong }

const ENameNotAllLettersOrNumbers: u64 = 3;
fun err_name_not_all_letters_or_numbers() { abort ENameNotAllLettersOrNumbers }

const EWrongAnswerOne: u64 = 4;
fun err_wrong_answer_one() { abort EWrongAnswerOne }

const EWrongAnswerTwo: u64 = 5;
fun err_wrong_answer_two() { abort EWrongAnswerTwo }

// Witness

public struct BeginnerVillage has drop {}

// Public Funs

public fun solve(
    world: &KapyWorld,
    crew: &mut KapyCrew,
    name: String,
    answer_1: u64,
    answer_2: bool,
    ctx: &mut TxContext,
) {
    // check 1
    if (name.length() < MIN_NAME_LENGTH) err_name_too_short();

    // check 2
    if (name.length() > MAX_NAME_LENGTH) err_name_too_long();

    // check 3
    if (!is_all_letters(&name)) err_name_not_all_letters_or_numbers();

    // check 4
    let crew_index_u64 = crew.index() as u64;
    let lucky_number = (crew_index_u64 * 618 + 3140) / crew_index_u64;
    if (answer_1 != lucky_number) err_wrong_answer_one();

    // check 5
    let index_is_even = crew.index() % 2 == 0;
    if (answer_2 != index_is_even) err_wrong_answer_two();

    // update username
    crew.update_name(name);

    // carry an orange if pass all checks
    let pirate = kapy_pirate::new(
        world,
        pirate_kind(),
        BeginnerVillage {},
        ctx,
    );
    crew.recruit(pirate);
}

// Getter Funs

public fun pirate_kind(): u8 { PIRATE_KIND }

// Internal Funs

fun is_letter_or_number(code: u8): bool {
    (code >= 65 && code < 65 + 26) || // range of uppercase letters
    (code >= 97 && code < 97 + 26) || // range of lowercase letters
    (code >= 48 && code < 48 + 10) // range of numbers
}

fun is_all_letters(string: &String): bool {
    let string_len = string.length();
    let string_bytes = string.as_bytes();
    let mut idx = 0;
    while (idx < string_len) {
        let char_ascii_code = *string_bytes.borrow(idx);
        if (!is_letter_or_number(char_ascii_code)) {
            return false
        };
        idx = idx + 1;
    };
    true
}
