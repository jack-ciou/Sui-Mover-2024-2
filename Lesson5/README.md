# Lesson 5

### Pacakge ID

```
0xbccf3732710974ca6ed41ee23e5328b9a6a63ee25ab0b1f25abeb6954a8467d1
```

### Update Display

```
sui client ptb \
--assign publisher @0x054de66991fc22281da529590ad269a1ee1df4b68084d7b5ae99fb9a3c04aeb1 \
--move-call 0xbccf3732710974ca6ed41ee23e5328b9a6a63ee25ab0b1f25abeb6954a8467d1::simple_nft::update_display publisher
```

### Exercise 5 Mint your Simple NFT

CLI commands

```
sui client ptb \
--assign name '"Simple NFT"' \
--assign description '"This is my first nft."' \
--assign url '"https://raw.githubusercontent.com/Typus-Lab/typus-asset/refs/heads/main/logo.png"' \
--make-move-vec '<0x1::string::String>' '["icon","owner","color"]' --assign attribute_keys \
--make-move-vec '<0x1::string::String>' '["Typus","Wayne","black"]' --assign attribute_values \
--move-call 0xbccf3732710974ca6ed41ee23e5328b9a6a63ee25ab0b1f25abeb6954a8467d1::simple_nft::mint_to_sender name description url attribute_keys attribute_values \
--gas-budget 10000000
```

### PPT

https://docs.google.com/presentation/d/1pUCkwEflglugZ5aRpLxmuifCacQMu0z4iXri_7EPlRY/edit?usp=sharing
