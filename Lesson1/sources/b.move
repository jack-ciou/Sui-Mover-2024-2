module lesson_1::b;

use std::string::{Self, String};
use lesson_1::a::A;

public struct B has store, copy, drop {
    last_words: String,
}

public fun echo(b: &mut B, a: &A) {
    // b.last_words = a.last_words; // can't read A's fields
    b.last_words = a.last_words();
}

public fun say_sorry_together(b: &mut B, a: &mut A) {
    b.last_words = sorry();
    a.say(sorry());
    // a.last_words = sorry(); // can't write A's fields
}

public fun last_words(b: &B): String {
    b.last_words
}

fun sorry(): String {
    string::utf8(b"sorry")
}
