import {SuiClient, getFullnodeUrl} from "@mysten/sui/client";
import {Ed25519Keypair} from "@mysten/sui/keypairs/ed25519";
import {Transaction, ObjectRef } from "@mysten/sui/transactions";
import dotenv from "dotenv";
dotenv.config();

// ============= Constants Configuration =============
// Hint: You need to specify the network, contract package, module, function, and arguments
const CONFIG = {
    // Network configuration
    NETWORK: 'testnet',
    CONTRACT: {
        // This is a dice rolling contract on testnet
        // You can use this contract to test your implementation
        PACKAGE: "0xd34b21549b175274b58c44a0e69e068b9e3932f94cc4c308016e336473543732",
        MODULE: "dice",
        FUNCTION: "roll",
        ARGUMENTS: {
            // The dice contract takes two objects as input:
            // 1. A dice object
            // 2. A random object
            DICE_OBJECT: "0x6601367c7e704f55b1610495ef0340905ed26f3d7c45219151243c7ed77dccc1",
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
const sponsor: Ed25519Keypair = Ed25519Keypair.fromSecretKey(process.env.SPONSOR_PRIVATE_KEY!); 
const sponsorAddress = sponsor.getPublicKey().toSuiAddress();
const senderAddress = sender.getPublicKey().toSuiAddress();
// ============= Transaction Building =============
const createSponsorTx = async(): Promise<Uint8Array> => {
    // TODO: Create a new transaction
    const tx = new Transaction();    
    // TODO: Add move call to your contract    
    // Hint: Use tx.moveCall with your contract configuration
 
    tx.moveCall({
        target: `${CONFIG.CONTRACT.PACKAGE}::${CONFIG.CONTRACT.MODULE}::${CONFIG.CONTRACT.FUNCTION}`,
        arguments: [
            tx.object(CONFIG.CONTRACT.ARGUMENTS.DICE_OBJECT),
            tx.object(CONFIG.CONTRACT.ARGUMENTS.RANDOM)
            // Add your arguments here, e.g., tx.pure('some_value'), tx.object('object_id')
            // Example: tx.pure(123), tx.object('0x...')
        ]
    });

    // TODO: Build and return the transaction
    // Hint: Use tx.build with client and onlyTransactionKind option
      const transactionBytes = await tx.build({
        client: client,
        onlyTransactionKind: true,
    });

    return transactionBytes // TODO: Replace with actual transaction bytes
}

// ============= Signature Handling =============
const sponsorSignTx = async(txBytes: Uint8Array): Promise<TransactionOutput> => {
    // TODO: Create transaction from bytes and set sender
    const tx = Transaction.fromKind(txBytes);
    
    // TODO: Get sponsor's coins for gas payment
    // Hint: You can either:
    // 1. Use client.getCoins to get all coins and select the first one (index 0)
    // 2. Use client.getObject to get a specific coin by its ID
    const result = await client.getCoins({
          owner: sponsorAddress,
          coinType: "0x2::sui::SUI"
        });
   
    // TODO: Check if sponsor has enough coins
    // Hint: Add error handling for insufficient gas
    if (!result || !result.data || !Array.isArray(result.data) || result.data.length === 0) {
        console.error("Sponsor does not have enough coins for gas payment.");
        throw new Error("Sponsor does not have enough coins for gas payment");
    }

    // TODO: Set gas owner and gas payment
    // Hint: Use tx.setGasOwner and tx.setGasPayment    
    // 將 Coin 物件陣列轉換為 ObjectRef 陣列
    tx.setSender(senderAddress);
    tx.setGasOwner(sponsorAddress);
    const payments: ObjectRef[] = result.data.map(coin => ({
        objectId: coin.coinObjectId,
        version: coin.version,
        digest: coin.digest,
    }));
    tx.setGasPayment(payments);

    // TODO: Sign the transaction      
    const signatureWithBytes = await sponsor.signTransaction(await tx.build({ client }));

    const signTx: TransactionOutput = {
        //txBytes: Buffer.from(signatureWithBytes.bytes).toString('base64'), // 將 Uint8Array 轉換為 base64 字串
        txBytes: signatureWithBytes.bytes,
        signature: signatureWithBytes.signature // 獲取簽名字串 
    };

    return signTx;
}
const senderSignTx = async(txBytes: string): Promise<TransactionOutput> => {
    // TODO: Sign the transaction with sender's keypair
    // Hint: Use sender.signTransaction 
   
    const signatureWithBytes = await sender.signTransaction(Buffer.from(txBytes, 'base64')); // 將 base64 字串轉換為 Uint8Array，並使用 sender.signTransaction 進行簽名txBytes);
    const signTx: TransactionOutput = {
        //txBytes: Buffer.from(signatureWithBytes.bytes).toString('base64'),
       txBytes: signatureWithBytes.bytes,
        signature: signatureWithBytes.signature
    };
    return signTx;
}

// ============= Transaction Execution =============
const executeTransaction = async(
    txBytes: string,
    sponsorSignature: string,
    senderSignature: string
): Promise<void> => {
    // Execute the transaction
    // Hint: Use client.executeTransactionBlock
    // 這個函式接收 base64 txBytes，轉換回 Uint8Array
    const bytes = Buffer.from(txBytes, 'base64');
    console.log("Executing transaction...");

    // 執行交易區塊，傳入位元組和所有簽名
    // signature 參數需要一個簽名字串的陣列
    try {
        const executeResponse = await client.executeTransactionBlock({
            transactionBlock:  bytes,
            signature: [senderSignature, sponsorSignature], // 包含所有必要的簽名
      
        });

        console.log("Transaction executed successfully!"); 
        await new Promise(resolve => setTimeout(resolve, 1000));

        // TODO: 根據 executeResponse 檢查交易狀態和結果
        if (executeResponse.digest.length > 0) {
            console.log("Transaction status: Success");
            console.log(`Transaction Digest: ${executeResponse.digest}`);
            // 您可以在這裡解析 effects 或 objectChanges 來獲取交易結果
        } else {
            console.error("Transaction status: Failed"); 
            throw new Error("Transaction execution failed");
        }

    } catch (error) {
        console.error("Error during transaction execution:", error);
        throw error; // 重新拋出錯誤以便上層捕獲
    }
}

// ============= Main Function =============
const main = async(): Promise<void> => {
    try {
        // TODO: Implement the main transaction flow
        // 1. Create transaction
        let tx = await createSponsorTx();

        // 2. Get sponsor signature
        let sponsorTx = await sponsorSignTx(tx);
        let sponsorSignature = sponsorTx.signature; 

        // 3. Get sender signature
        let senderTx = await senderSignTx(sponsorTx.txBytes);
        let senderSignature = senderTx.signature;

        // 4. Execute transaction
        await executeTransaction(sponsorTx.txBytes, sponsorSignature, senderSignature);
    } catch (error) {
        console.error("Transaction failed:", error);        
    }
        // Hint: Follow the sequence of steps and handle errors appropriately
}

// Execute main function
main().catch(console.error);