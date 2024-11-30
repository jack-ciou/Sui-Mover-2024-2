#[test_only]
module lesson_2::lesson_2_tests;

use lesson_2::lesson_2;
use std::debug;
use std::type_name;

#[test]
fun test_hello_world() {
    debug::print(&lesson_2::hello_world());
}

#[test]
fun test_sum() {
    let sum_result = lesson_2::sum(1, 2);
    debug::print(&sum_result);
    assert!(sum_result == 3);
}

#[test]
fun test_vector() {
    let mut numbers = lesson_2::numbers();
    debug::print(&numbers);
    numbers.push_back(4);
    debug::print(&numbers);
    numbers.pop_back();
    debug::print(&numbers);

    let mut idx = 0;
    while (idx < numbers.length()) {
        let num = numbers.borrow(idx);
        debug::print(num);
        idx = idx + 1;
    };
    debug::print(&numbers);

    let mut idx = 0;
    loop {
        if (idx >= numbers.length()) break;
        let num = numbers.borrow(idx);
        debug::print(num);
        idx = idx + 1;
    };
    debug::print(&numbers);
}

#[test]
fun test_option() {
    let numbers = lesson_2::numbers();

    let opt = lesson_2::try_borrow(&numbers, 0);
    debug::print(&opt);
    assert!(opt.is_some());

    let opt = lesson_2::try_borrow(&numbers, 3);
    debug::print(&opt);
    assert!(opt.is_none());
}

#[test]
fun test_type_name() {
    debug::print(&type_name::get<u64>());
    debug::print(&type_name::get<vector<u64>>());
    debug::print(&type_name::get<Option<u64>>());
}
