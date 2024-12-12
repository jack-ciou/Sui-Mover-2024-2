import { Transaction } from "@mysten/sui/transactions";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { client } from "./config";

// TODO: fill in the private key or phrase of the KapyCrew owner account
const signer = Ed25519Keypair.fromSecretKey("suiprivkey...");
// const signer = Ed25519Keypair.deriveKeypairFromSeed(
//   "test test test test test test test test test test test junk",
// );

// TODO: correct package ID
const EXERCISE_2_PACKAGE = "";

async function main() {
  const myKapyCrewId = ""; // TODO: correct KapyCrew ID
  const pickaxeStoreId = ""; // TODO: correct PickaxeStore ID
  const correctMineId = ""; // TODO: correct Mine ID
  const tier = 0; // TODO: enough tier to mine high quality Ore

  // create a transaction
  const tx = new Transaction();

  // build needed objects
  const myKapyCrew = tx.object(myKapyCrewId);
  const pickaxeStore = tx.object(pickaxeStoreId);
  const correctMine = tx.object(correctMineId);

  // split SUI coin for needed amount
  const [payment] = tx.splitCoins(tx.gas, [tier * 10]);

  // buy the pickaxe. TODO: fill in correct target
  const [pickaxe] = tx.moveCall({
    target: `${EXERCISE_2_PACKAGE}::module::function`,
    arguments: [pickaxeStore, tx.pure.u8(tier), payment],
  });

  // eploit to get Ore. TODO: fill in correct target and arguments
  const [ore] = tx.moveCall({
    target: `${EXERCISE_2_PACKAGE}::module::function`,
    arguments: [
      /* 3 arguments here */
    ],
  });

  tx.moveCall({
    target: `${EXERCISE_2_PACKAGE}::pickaxe::destroy`,
    arguments: [pickaxe],
  });

  // forge the Ore to get Sword. TODO: fill in correct target and arguments
  const [sword] = tx.moveCall({
    target: `${EXERCISE_2_PACKAGE}::module::function`,
    arguments: [
      /* 1 argument here */
    ],
  });

  // recruit the pirate with the sword. TODO: fill in correct arguments
  tx.moveCall({
    target: `${EXERCISE_2_PACKAGE}::swordsman_village::recurit`,
    arguments: [
      /* 3 arguments here */
    ],
  });

  // sign and send the transaction
  const res = await client.signAndExecuteTransaction({
    transaction: tx,
    signer,
    options: {
      showEvents: true,
    },
  });
  console.log(res.events);
}

main().catch((err) => console.log(err));
