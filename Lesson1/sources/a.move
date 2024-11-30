module lesson_1::a;

use std::string::{Self, String};

public struct A has store, copy, drop {
    last_words: String,
}

public fun say(a: &mut A, words: String) {
    a.last_words = words;
}

public fun say_hello(a: &mut A) {
    a.say(hello())
}

public fun last_words(a: &A): String {
    a.last_words
}

fun hello(): String {
    string::utf8(b"hello")
}
