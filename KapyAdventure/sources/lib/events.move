module kapy_adventure::events;

// Dependencies

use sui::event;

// Events

public struct NewCrew has copy, drop {
    id: ID,
    index: u32,
}

public(package) fun emit_new_crew(id: ID, index: u32) {
    event::emit(NewCrew { id, index });
}

public struct NewPirate has copy, drop {
    id: ID,
    kind: u8,
}

public(package) fun emit_new_pirate(id: ID, kind: u8) {
    event::emit(NewPirate  { id, kind })
}

public struct Recruit has copy, drop {
    crew_id: ID,
    crew_index: u32,
    crew_strength: u16,
    pirate_kind: u8,
}

public(package) fun emit_recruit(
    crew_id: ID,
    crew_index: u32,
    crew_strength: u16,
    pirate_kind: u8,
) {
    event::emit(Recruit { crew_id, crew_index, crew_strength, pirate_kind });
}

public struct AddTreasure has copy, drop {
    amount: u64,
}

public(package) fun emit_add_treasure(amount: u64) {
    event::emit(AddTreasure { amount });
}

public struct FoundTreasure has copy, drop {
    crew_id: ID,
    crew_index: u32,
    strength: u16,
}

public(package) fun emit_found_treasure(
    crew_id: ID,
    crew_index: u32,
    strength: u16,
) {
    event::emit(FoundTreasure { crew_id, crew_index, strength });
}