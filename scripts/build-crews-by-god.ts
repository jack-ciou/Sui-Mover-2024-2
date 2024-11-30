import { Transaction } from "@mysten/sui/transactions";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { PRIVATE_KEY } from "./private-key";

const client = new SuiClient({ url: getFullnodeUrl("mainnet") });

const signer = Ed25519Keypair.fromSecretKey(PRIVATE_KEY);

const recipients = [
  "0xf9055079caa4e7d403bc93c57768e7530923d6581f104e14736756e38896f604",
];

const KAPY_ADVENTURE_PACKGE_ID = "0xc00d69e58132d45903419bd1734cf0ce6b61352d9eedb241cfd2d0cad32e1de8";
const KAPY_WORLD_OBJECT_ID = "0x068d5ff571b34d02fbe1cd0a8f748d496e3f626a4833bb238900e090343482e4";
const KAPY_GOD_POWER_OBJECT_ID = "0x855da207a12b73330555a738694ad189b87fc859f287ebc0b36feb919ea96893";

async function main() {
  const tx = new Transaction();
  for (const recipient of recipients) {
    const [kapyCrew] = tx.moveCall({
      target: `${KAPY_ADVENTURE_PACKGE_ID}::kapy_crew::build_crew_by_god`,
      arguments: [
        tx.object(KAPY_WORLD_OBJECT_ID),
        tx.object(KAPY_GOD_POWER_OBJECT_ID),
        tx.pure.string(""),
      ],
    });
    tx.transferObjects([kapyCrew], recipient);
  };
  
  const res = await client.signAndExecuteTransaction({
    transaction: tx,
    signer,
    options: {
      showEffects: true,
    }
  });
  console.log(res.effects?.created);
}

main().catch(err => console.log(err));

