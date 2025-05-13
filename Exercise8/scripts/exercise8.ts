import {SuiClient, getFullnodeUrl} from "@mysten/sui/client";
import {Ed25519Keypair} from "@mysten/sui/keypairs/ed25519";
import {Transaction} from "@mysten/sui/transactions";
import {fromBase64} from "@mysten/utils"

// ============= Constants Configuration =============
// Hint: You need to specify the network, contract package, module, function, and arguments
const CONFIG = {
    // Network configuration
    NETWORK: 'testnet',
    CONTRACT: {
        // This is a dice rolling contract on testnet
        // You can use this contract to test your implementation
        PACKAGE: "0xc0e57ef52ab1397e204ad10830c140e0a0852e8b560f9f6f960c9e32ccb90940",
        MODULE: "dice",
        FUNCTION: "roll",
        ARGUMENTS: {
            // The dice contract takes two objects as input:
            // 1. A dice object
            // 2. A random object
            DICE_OBJECT: "0x1860e9758c38555dde4eec45abec6e269ab43ffcd392611abb5d399835b5364f",
            RANDOM: "0x8"
        }
    }
} as const;

// Note: This contract is a dice rolling contract
// The function signature is: entry fun roll(dice: &mut Dice, random: &mut Random, ctx: &mut TxContext)
// You can find the contract on Sui Explorer: https://testnet.suivision.xyz/package/0xc0e57ef52ab1397e204ad10830c140e0a0852e8b560f9f6f960c9e32ccb90940

// ============= Type Definitions =============
interface TransactionOutput {
    txBytes: string;
    signature: string;
}

// ============= Client and Keypair Initialization =============
// Hint: Use getFullnodeUrl with the network from CONFIG
const client = new SuiClient({
    url: getFullnodeUrl(CONFIG.NETWORK)
});

// TODO: Initialize keypairs for sender and sponsor
// Hint: Use Ed25519Keypair.fromSecretKey with environment variables
const sender: Ed25519Keypair = Ed25519Keypair.fromSecretKey(process.env.SENDER_PRIVATE_KEY!); 
const sponsor: Ed25519Keypair = Ed25519Keypair.fromSecretKey(process.env.SENDER_PRIVATE_KEY!); 

// ============= Transaction Building =============
const createSponsorTx = async(): Promise<Uint8Array> => {
    // TODO: Create a new transaction
    
    // TODO: Add move call to your contract
    // Hint: Use tx.moveCall with your contract configuration
    
    // TODO: Build and return the transaction
    // Hint: Use tx.build with client and onlyTransactionKind option
    return new Uint8Array(); // TODO: Replace with actual transaction bytes
}

// ============= Signature Handling =============
const sponsorSignTx = async(txBytes: Uint8Array): Promise<TransactionOutput> => {
    // TODO: Create transaction from bytes and set sender
    const tx = Transaction.fromKind(txBytes);
    
    // TODO: Get sponsor's coins for gas payment
    // Hint: You can either:
    // 1. Use client.getCoins to get all coins and select the first one (index 0)
    // 2. Use client.getObject to get a specific coin by its ID
    
    // TODO: Check if sponsor has enough coins
    // Hint: Add error handling for insufficient gas
    
    // TODO: Set gas owner and gas payment
    // Hint: Use tx.setGasOwner and tx.setGasPayment
    
    // TODO: Sign the transaction
    // Hint: Use tx.sign with sponsor keypair
    
    // TODO: Return signature and transaction bytes
    return {
        txBytes: "",
        signature: ""
    };
}

const senderSignTx = async(txBytes: string): Promise<TransactionOutput> => {
    // TODO: Sign the transaction with sender's keypair
    // Hint: Use sender.signTransaction 
    return {
        txBytes: "",
        signature: ""
    };
}

// ============= Transaction Execution =============
const executeTransaction = async(
    txBytes: string,
    sponsorSignature: string,
    senderSignature: string
): Promise<void> => {
    // TODO: Execute the transaction
    // Hint: Use client.executeTransactionBlock
}

// ============= Main Function =============
const main = async(): Promise<void> => {
    try {
        // TODO: Implement the main transaction flow
        // 1. Create transaction
        // 2. Get sponsor signature
        // 3. Get sender signature
        // 4. Execute transaction
        // Hint: Follow the sequence of steps and handle errors appropriately
    } catch (error) {
        console.error("Transaction failed:", error);
    }
}

// Execute main function
main().catch(console.error);