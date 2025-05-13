# Exercise 8: Sponsored Transaction Implementation on Sui Blockchain

## Overview
This exercise focuses on implementing a sponsored transaction (also known as a gasless transaction) on the Sui blockchain. The implementation uses a dice rolling contract on the Sui testnet as a practical example.

## Contract Details
- **Network**: Sui Testnet
- **Contract Package**: `0xc0e57ef52ab1397e204ad10830c140e0a0852e8b560f9f6f960c9e32ccb90940`
- **Module**: `dice`
- **Function**: `roll`
- **Function Signature**: `entry fun roll(dice: &mut Dice, random: &mut Random, ctx: &mut TxContext)`
- **Contract Explorer**: [View on Sui Vision](https://testnet.suivision.xyz/package/0xc0e57ef52ab1397e204ad10830c140e0a0852e8b560f9f6f960c9e32ccb90940)
- **Required Object IDs**:
  - Dice Object: `0x1860e9758c38555dde4eec45abec6e269ab43ffcd392611abb5d399835b5364f`
  - Random Object: `0x8`

## Implementation Requirements

Complete the TODO sections in the `exercise8.ts` template located in the `scripts` folder. 

## Submission Format

Please submit your implementation in the group chat with:

1. **GitHub Repository Link**
   - Share the link to your GitHub repository containing the implementation
   - Make sure the repository is public and accessible

2. **Transaction Digest**
   ```
   Your transaction digest here
   ```
