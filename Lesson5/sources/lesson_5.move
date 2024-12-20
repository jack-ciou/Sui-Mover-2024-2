// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module lesson_5::simple_nft {

    use std::string::{Self, String};
    use sui::{event, url::{Self, Url}};
    use sui::vec_map::{Self, VecMap};
    use sui::display;
    use sui::package::Publisher;


    /// An example NFT that can be minted by anybody
    public struct SimpleNFT has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
        /// Allow custom attributes
        attributes: VecMap<String, String>,
    }

    // ===== Events =====

    public struct NFTMinted has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: string::String,
    }

    /// One time witness is only instantiated in the init method
    public struct SIMPLE_NFT has drop {}

    fun init(otw: SIMPLE_NFT, ctx: &mut TxContext) {
        sui::package::claim_and_keep(otw, ctx);
    }

    #[lint_allow(self_transfer)]
    entry fun update_display(publisher: &Publisher, ctx: &mut TxContext) {
        let mut display = display::new<SimpleNFT>(publisher, ctx);
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"{url}"));
        display::add(&mut display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::add(&mut display, string::utf8(b"link"), string::utf8(b"https://suivision.xyz/object/{id}"));
        display::add(&mut display, string::utf8(b"project_url"), string::utf8(b"https://t.me/suimover"));
        display::add(&mut display, string::utf8(b"creator"), string::utf8(b"Sui Mover"));

        display::update_version(&mut display);

        let sender = tx_context::sender(ctx);
        transfer::public_transfer(display, sender);
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &SimpleNFT): &string::String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &SimpleNFT): &string::String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &SimpleNFT): &Url {
        &nft.url
    }

    // ===== Entrypoints =====

    #[allow(lint(self_transfer))]
    /// Create a new simple_nft
    public fun mint_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        ctx: &mut TxContext,
    ) {
        let sender = ctx.sender();
        let nft = SimpleNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            attributes: vec_map::from_keys_values(attribute_keys, attribute_values),
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
        });

        transfer::public_transfer(nft, sender);
    }

    /// Transfer `nft` to `recipient`
    public fun transfer(nft: SimpleNFT, recipient: address, _: &mut TxContext) {
        transfer::public_transfer(nft, recipient)
    }

    /// Update the `description` of `nft` to `new_description`
    public fun update_description(
        nft: &mut SimpleNFT,
        new_description: vector<u8>,
        _: &mut TxContext,
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete `nft`
    public fun burn(nft: SimpleNFT, _: &mut TxContext) {
        let SimpleNFT { id, name: _, description: _, url: _, attributes: _ } = nft;
        id.delete()
    }

}